#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
budgetcheck.py — 从今天(或开始日)到目标日期,按固定开销 + 饮食习惯逐日累加,
判断当前余额够不够撑到目标日期。

两种用法:
  1) 直接 `budgetcheck`(无参数)→ 交互式,逐条问你余额/日期/最近支出扣没扣费。
  2) `budgetcheck --balance ... --target ...`(带参数)→ 一次性算,适合脚本复用。

配置(单价/周期/星期/扣费日等稳定项)放 ~/.config/budgetcheck/config.json,
首次运行自动生成默认模板。

金额全程用 Decimal(两位小数);日期/日历用 datetime + calendar,不碰 shell 的 BSD date。
"""

import argparse
import calendar
import json
import os
import sys
import unicodedata
from datetime import date, timedelta
from decimal import Decimal, ROUND_HALF_UP

if sys.version_info < (3, 6):
    sys.stderr.write("需要 python3 (>=3.6)。当前: %s\n" % sys.version.split()[0])
    sys.exit(1)

CONFIG_DIR = os.path.expanduser("~/.config/budgetcheck")
CONFIG_PATH = os.path.join(CONFIG_DIR, "config.json")

_WEEKDAY_NAMES = {
    "monday": 0, "mon": 0,
    "tuesday": 1, "tue": 1, "tues": 1,
    "wednesday": 2, "wed": 2,
    "thursday": 3, "thu": 3, "thur": 3, "thurs": 3,
    "friday": 4, "fri": 4,
    "saturday": 5, "sat": 5,
    "sunday": 6, "sun": 6,
}
_WEEKDAY_CN = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]

DEFAULTS = {
    "_comment": "budgetcheck 配置。改完直接保存即可。金额单位与你输入的余额一致。",
    "lunch_base": 16,
    "lunch_weekend": 30,
    "weekend_lunch_weekday": "Sunday",

    "egg_price": 12.70,
    "egg_cycle_days": 9,
    "milk_price": 10.50,
    "milk_cycle_days": 9,

    "gym_price": 16.95,
    "gym_weekday": "Friday",
    "laundry_price": 11,
    "laundry_weekday": "Saturday",

    "claude_code_price": 30,
    "claude_code_billing_day": 31,

    "openai_price": 30,
    "openai_billing_day": 5,

    "apple_price": 14.99,
    "apple_billing_day": 5,

    "phone_price": 30,
    "phone_billing_day": 10,

    "rent_weekly": 400,
    "rent_pay_day": 23,
}

REQUIRED_KEYS = [k for k in DEFAULTS if k != "_comment"]


# ---------------------------------------------------------------- 基础工具

def D(x):
    return Decimal(str(x))


def q2(x):
    return x.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)


def fmt(x):
    return "-" if x is None else "%.2f" % x


def signed(x):
    return ("+%.2f" % x) if x >= 0 else ("%.2f" % x)


def parse_weekday(name, field):
    key = str(name).strip().lower()
    if key not in _WEEKDAY_NAMES:
        raise ValueError("配置 %s 的星期名无法识别: %r" % (field, name))
    return _WEEKDAY_NAMES[key]


def parse_date(s, default_year):
    s = str(s).strip().lower()
    if s in ("today", "now", "今天", ""):
        return date.today()
    parts = s.replace("/", "-").split("-")
    try:
        if len(parts) == 3:
            y, m, d = int(parts[0]), int(parts[1]), int(parts[2])
        elif len(parts) == 2:
            y, m, d = default_year, int(parts[0]), int(parts[1])
        else:
            raise ValueError
        return date(y, m, d)
    except ValueError:
        raise ValueError("无法解析日期: %r (支持 today / YYYY-MM-DD / MM-DD)" % s)


def month_last_day(year, month):
    return calendar.monthrange(year, month)[1]


def next_month(year, month):
    return (year + 1, 1) if month == 12 else (year, month + 1)


def clamp_billing_day(day, year, month):
    return min(int(day), month_last_day(year, month))


# 中文对齐:按 Unicode East Asian Width 算显示宽度。
# 宽(W)/全角(F)= 2 格;其余(含带圈数字 ①② 这类 Ambiguous)= 1 格,
# 与 Ghostty 等现代终端的渲染一致。
def _wlen(s):
    w = 0
    for ch in s:
        w += 2 if unicodedata.east_asian_width(ch) in ("W", "F") else 1
    return w


def _pad(s, width):
    return s + " " * max(0, width - _wlen(s))


def _rpad(s, width):
    return " " * max(0, width - _wlen(s)) + s


# ---------------------------------------------------------------- 配置

def load_config(path):
    warnings = []
    if not os.path.exists(path):
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w", encoding="utf-8") as f:
            json.dump(DEFAULTS, f, ensure_ascii=False, indent=2)
        warnings.append("首次运行,已生成默认配置: %s (可自行编辑)" % path)
        return dict(DEFAULTS), warnings

    try:
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
    except Exception as e:
        raise ValueError("读取配置失败 %s: %s" % (path, e))

    cfg = dict(DEFAULTS)
    missing, nulled = [], []
    for k in REQUIRED_KEYS:
        if k not in data:
            missing.append(k)
        elif data[k] is None:
            nulled.append(k)
            cfg[k] = None
        else:
            cfg[k] = data[k]
    if missing:
        warnings.append("配置缺少以下项,已用默认值: " + ", ".join(missing))
    if nulled:
        warnings.append("配置中以下项为 null,将跳过对应开销(不计入): " + ", ".join(nulled))
    return cfg, warnings


# ---------------------------------------------------------------- 参数容器

class Params(object):
    def __init__(self):
        self.balance = None
        self.start = None
        self.target = None
        self.egg_stock_days = None
        self.milk_stock_days = None
        self.ate_lunch_today = False
        self.paid_gym_today = False
        self.paid_laundry_today = False
        self.phone_paid_this_month = False
        self.apple_paid_this_month = False
        self.claude_code_paid_this_month = False
        self.openai_paid_this_month = False
        self.openai_billing_day = None


# ---------------------------------------------------------------- 交互式提问

def _ask(prompt):
    try:
        return input(prompt)
    except EOFError:
        return ""


def ask_money(prompt):
    while True:
        raw = _ask("%s (数字, 例如 2958.36): " % prompt).strip()
        if not raw:
            print("  (必填)")
            continue
        try:
            return q2(D(raw))
        except Exception:
            print("  不是合法金额,再来一次(例如 2958.36)")


def ask_date(prompt, default=None):
    fmt_hint = " (YYYY-MM-DD / MM-DD / today)"
    dft = " [默认 %s]" % default if default else ""
    while True:
        raw = _ask("%s%s%s: " % (prompt, fmt_hint, dft)).strip()
        if not raw and default:
            raw = default
        if not raw:
            print("  (必填,格式 YYYY-MM-DD 或 MM-DD 或 today)")
            continue
        try:
            return parse_date(raw, date.today().year)
        except ValueError as e:
            print("  %s" % e)


def ask_int(prompt, default):
    while True:
        raw = _ask("%s [默认 %d]: " % (prompt, default)).strip()
        if not raw:
            return default
        try:
            return int(raw)
        except ValueError:
            print("  请输入整数")


def ask_yesno(prompt, default=False):
    d = "Y/n" if default else "y/N"
    while True:
        raw = _ask("%s [%s]: " % (prompt, d)).strip().lower()
        if not raw:
            return default
        if raw in ("y", "yes", "是", "对", "扣了", "付了", "吃了"):
            return True
        if raw in ("n", "no", "否", "没", "没有", "还没"):
            return False
        print("  请回答 y 或 n")


def stock_days_from_days_ago(days_ago, cycle):
    """几天前买的 → 相对开始日的库存天数(=下次补货落在第几天)。
    今天买(0)→ 满周期;每过一天减 1;已到期则今天就得补(1)。"""
    return max(1, cycle - int(days_ago))


def interactive_flow(cfg):
    print("")
    print("=== budgetcheck 交互模式 ===  (直接回车用默认值)")
    print("")

    p = Params()
    p.balance = ask_money("当前余额")
    p.start = ask_date("开始日期(算账起点)", default="today")
    p.target = ask_date("目标日期(要撑到哪天)")

    if p.target < p.start:
        print("目标日期早于开始日期,请重来。")
        sys.exit(1)

    print("")
    start = p.start
    is_start_today = (start == date.today())
    day_word = "今天" if is_start_today else ("开始日 %s" % start)

    # 午饭
    if cfg.get("lunch_base") is not None:
        p.ate_lunch_today = ask_yesno("%s午饭已经吃了吗?(吃了就不算这顿)" % day_word, default=False)

    # 鸡蛋 / 牛奶:问几天前买的
    egg_cycle = int(cfg["egg_cycle_days"]) if cfg.get("egg_cycle_days") else 0
    milk_cycle = int(cfg["milk_cycle_days"]) if cfg.get("milk_cycle_days") else 0
    if cfg.get("egg_price") is not None and egg_cycle > 0:
        da = ask_int("鸡蛋:上次几天前买的?(今天=0,昨天=1)", default=0)
        p.egg_stock_days = stock_days_from_days_ago(da, egg_cycle)
    if cfg.get("milk_price") is not None and milk_cycle > 0:
        da = ask_int("牛奶:上次几天前买的?(今天=0,昨天=1)", default=0)
        p.milk_stock_days = stock_days_from_days_ago(da, milk_cycle)

    # 今天(开始日)命中的周期性项:只有命中当天才问
    wd = start.weekday()
    if cfg.get("gym_price") is not None:
        gym_wd = parse_weekday(cfg["gym_weekday"], "gym_weekday")
        if wd == gym_wd:
            p.paid_gym_today = ask_yesno("%s是健身日,健身房这笔已经扣了吗?" % day_word, default=False)
    if cfg.get("laundry_price") is not None:
        laundry_wd = parse_weekday(cfg["laundry_weekday"], "laundry_weekday")
        if wd == laundry_wd:
            p.paid_laundry_today = ask_yesno("%s是洗衣日,洗衣这笔已经付了吗?" % day_word, default=False)

    # 每月项:只有「本月这笔落在窗口内(扣费日 >= 开始日那天)」才问
    lastday = month_last_day(start.year, start.month)

    def month_charge_pending(billing_day):
        eff = clamp_billing_day(billing_day, start.year, start.month)
        d = date(start.year, start.month, eff)
        return start <= d <= p.target

    if cfg.get("phone_price") is not None and cfg.get("phone_billing_day"):
        if month_charge_pending(cfg["phone_billing_day"]):
            p.phone_paid_this_month = ask_yesno(
                "话费(约每月 %s 号)这个月已经扣了吗?" % cfg["phone_billing_day"], default=False)

    if cfg.get("apple_price") is not None and cfg.get("apple_billing_day"):
        if month_charge_pending(cfg["apple_billing_day"]):
            p.apple_paid_this_month = ask_yesno(
                "Apple(约每月 %s 号)这个月已经扣了吗?" % cfg["apple_billing_day"], default=False)

    if cfg.get("claude_code_price") is not None and cfg.get("claude_code_billing_day"):
        if month_charge_pending(cfg["claude_code_billing_day"]):
            p.claude_code_paid_this_month = ask_yesno(
                "Claude Code(每月 %s 号)这个月已经扣了吗?" % cfg["claude_code_billing_day"], default=False)

    if cfg.get("openai_price") is not None:
        cfg_day = cfg.get("openai_billing_day")
        p.openai_billing_day = ask_int(
            "OpenAI 这个月预计几号扣费?", default=cfg_day if cfg_day else 5)
        if month_charge_pending(p.openai_billing_day):
            p.openai_paid_this_month = ask_yesno(
                "OpenAI(每月 %s 号)这个月已经扣了吗?" % p.openai_billing_day, default=False)

    print("")
    return p


def params_from_args(args, cfg):
    p = Params()
    try:
        p.balance = q2(D(args.balance))
    except Exception:
        raise ValueError("--balance 不是合法数字: %r" % args.balance)
    y = date.today().year
    p.start = parse_date(args.start, y)
    p.target = parse_date(args.target, y)

    egg_cycle = int(cfg["egg_cycle_days"]) if cfg.get("egg_cycle_days") else 0
    milk_cycle = int(cfg["milk_cycle_days"]) if cfg.get("milk_cycle_days") else 0
    p.egg_stock_days = args.egg_stock_days if args.egg_stock_days is not None else egg_cycle
    p.milk_stock_days = args.milk_stock_days if args.milk_stock_days is not None else milk_cycle

    p.ate_lunch_today = args.ate_lunch_today
    p.paid_gym_today = args.paid_gym_today
    p.paid_laundry_today = args.paid_laundry_today
    p.phone_paid_this_month = args.phone_paid_this_month
    p.apple_paid_this_month = args.apple_paid_this_month
    p.claude_code_paid_this_month = args.claude_code_paid_this_month
    p.openai_paid_this_month = args.openai_paid_this_month
    return p


def equivalent_command(p):
    """把交互结果转成等价的命令行,方便下次直接复用。"""
    parts = ["budgetcheck",
             "--balance %s" % p.balance,
             "--start %s" % p.start,
             "--target %s" % p.target]
    if p.egg_stock_days is not None:
        parts.append("--egg-stock-days %d" % p.egg_stock_days)
    if p.milk_stock_days is not None:
        parts.append("--milk-stock-days %d" % p.milk_stock_days)
    for flag, on in [("--ate-lunch-today", p.ate_lunch_today),
                     ("--paid-gym-today", p.paid_gym_today),
                     ("--paid-laundry-today", p.paid_laundry_today),
                     ("--phone-paid-this-month", p.phone_paid_this_month),
                     ("--apple-paid-this-month", p.apple_paid_this_month),
                     ("--claude-code-paid-this-month", p.claude_code_paid_this_month),
                     ("--openai-paid-this-month", p.openai_paid_this_month)]:
        if on:
            parts.append(flag)
    return " ".join(parts)


# ---------------------------------------------------------------- 核心计算 + 输出

def compute_and_report(cfg, warnings, p, show_command=False):
    weekend_wd = parse_weekday(cfg["weekend_lunch_weekday"], "weekend_lunch_weekday")
    gym_wd = parse_weekday(cfg["gym_weekday"], "gym_weekday") if cfg.get("gym_price") is not None else None
    laundry_wd = parse_weekday(cfg["laundry_weekday"], "laundry_weekday") if cfg.get("laundry_price") is not None else None

    start, target, balance = p.start, p.target, p.balance
    window_days = (target - start).days + 1

    egg_cycle = int(cfg["egg_cycle_days"]) if cfg.get("egg_cycle_days") else 0
    milk_cycle = int(cfg["milk_cycle_days"]) if cfg.get("milk_cycle_days") else 0

    def is_restock(day_number, stock, cycle):
        if not stock or cycle <= 0 or stock <= 0:
            return False
        return day_number >= stock and (day_number - stock) % cycle == 0

    items = {}

    def add(item, amount):
        rec = items.setdefault(item, [0, Decimal("0.00")])
        rec[0] += 1
        rec[1] += amount

    lunch_weekday_total = Decimal("0.00")
    lunch_real_total = Decimal("0.00")
    weekday_lunch_count = 0
    weekend_lunch_count = 0

    lunch_base = D(cfg["lunch_base"]) if cfg.get("lunch_base") is not None else None
    lunch_weekend = D(cfg["lunch_weekend"]) if cfg.get("lunch_weekend") is not None else lunch_base

    d = start
    offset = 0
    while d <= target:
        day_number = offset + 1
        is_start = (offset == 0)
        wd = d.weekday()
        in_start_month = (d.year == start.year and d.month == start.month)

        if lunch_base is not None and not (is_start and p.ate_lunch_today):
            lunch_weekday_total += lunch_base
            if wd == weekend_wd:
                lunch_real_total += lunch_weekend
                weekend_lunch_count += 1
            else:
                lunch_real_total += lunch_base
                weekday_lunch_count += 1

        if cfg.get("egg_price") is not None and is_restock(day_number, p.egg_stock_days, egg_cycle):
            add("鸡蛋", q2(D(cfg["egg_price"])))
        if cfg.get("milk_price") is not None and is_restock(day_number, p.milk_stock_days, milk_cycle):
            add("牛奶", q2(D(cfg["milk_price"])))

        if gym_wd is not None and wd == gym_wd and not (is_start and p.paid_gym_today):
            add("健身房", q2(D(cfg["gym_price"])))
        if laundry_wd is not None and wd == laundry_wd and not (is_start and p.paid_laundry_today):
            add("洗衣", q2(D(cfg["laundry_price"])))

        if cfg.get("claude_code_price") is not None and cfg.get("claude_code_billing_day"):
            if d.day == clamp_billing_day(cfg["claude_code_billing_day"], d.year, d.month):
                if not (p.claude_code_paid_this_month and in_start_month):
                    add("Claude Code", q2(D(cfg["claude_code_price"])))

        if cfg.get("openai_price") is not None:
            obd = p.openai_billing_day if p.openai_billing_day is not None else cfg.get("openai_billing_day")
            if obd is not None:
                if d.day == clamp_billing_day(obd, d.year, d.month):
                    if not (p.openai_paid_this_month and in_start_month):
                        add("OpenAI", q2(D(cfg["openai_price"])))

        if cfg.get("apple_price") is not None and cfg.get("apple_billing_day"):
            if d.day == clamp_billing_day(cfg["apple_billing_day"], d.year, d.month):
                if not (p.apple_paid_this_month and in_start_month):
                    add("Apple", q2(D(cfg["apple_price"])))

        if cfg.get("phone_price") is not None and cfg.get("phone_billing_day"):
            if d.day == clamp_billing_day(cfg["phone_billing_day"], d.year, d.month):
                if not (p.phone_paid_this_month and in_start_month):
                    add("话费", q2(D(cfg["phone_price"])))

        # 房租: config 的 rent_weekly 是「周租金」,付下个月 = 周租/7 × 下月天数。
        # 注意这里是精确日匹配(刻意不 clamp),pay_day 若为 29/30/31,
        # 平月/2 月会整笔跳过 —— 语义待确认,别顺手改成 clamp。
        if cfg.get("rent_weekly") is not None and cfg.get("rent_pay_day"):
            if d.day == int(cfg["rent_pay_day"]):
                ny, nm = next_month(d.year, d.month)
                amt = q2(D(cfg["rent_weekly"]) / D(7) * D(month_last_day(ny, nm)))
                add("房租", amt)

        offset += 1
        d += timedelta(days=1)

    fixed_total = sum((rec[1] for rec in items.values()), Decimal("0.00"))
    total1 = q2(fixed_total + lunch_weekday_total)
    total2 = q2(fixed_total + lunch_real_total)
    surplus1 = q2(balance - total1)
    surplus2 = q2(balance - total2)

    out = sys.stdout.write
    out("\n")
    out("预算检查  %s → %s  (%d 天, 含两端)\n" % (start, target, window_days))
    out("开始日 %s(%s)   余额 %s\n\n" % (start, _WEEKDAY_CN[start.weekday()], fmt(balance)))

    for w in warnings:
        out("⚠ %s\n" % w)
    if warnings:
        out("\n")

    # ---- 明细表(真实吃法 场景②)----
    rows = []
    if lunch_base is not None:
        rows.append(("午饭·平日 %s" % fmt(lunch_base), weekday_lunch_count,
                     q2(lunch_base * weekday_lunch_count)))
        if weekend_lunch_count:
            rows.append(("午饭·%s %s" % (_WEEKDAY_CN[weekend_wd], fmt(lunch_weekend)),
                         weekend_lunch_count, q2(lunch_weekend * weekend_lunch_count)))
    for name in ["鸡蛋", "牛奶", "健身房", "洗衣", "Claude Code", "OpenAI", "Apple", "话费", "房租"]:
        if name in items:
            rows.append((name, items[name][0], q2(items[name][1])))

    name_w = max([_wlen(r[0]) for r in rows] + [10])
    line = "─" * (name_w + 23)
    out("┌%s┐\n" % line)
    out("│ %s %s %s │\n" % (_pad("项目", name_w), _rpad("次数", 6), _rpad("小计", 13)))
    out("├%s┤\n" % line)
    for name, cnt, sub in rows:
        out("│ %s %6d %13s │\n" % (_pad(name, name_w), cnt, fmt(sub)))
    out("├%s┤\n" % line)
    out("│ %s %6s %13s │\n" % (_pad("总计(场景②)", name_w), "", fmt(total2)))
    out("└%s┘\n\n" % line)

    # ---- 场景对比表 ----
    out("场景对比:\n")
    sc_w = 22
    out("┌%s┬%s┬%s┐\n" % ("─" * (sc_w + 2), "─" * 13, "─" * 12))
    out("│ %s │ %s │ %s │\n" % (_pad("场景", sc_w), _rpad("支出", 11), _rpad("结余", 10)))
    out("├%s┼%s┼%s┤\n" % ("─" * (sc_w + 2), "─" * 13, "─" * 12))
    out("│ %s │ %11s │ %10s │\n" % (
        _pad("① 平日午饭(全 %s)" % fmt(lunch_base), sc_w), fmt(total1), signed(surplus1)))
    out("│ %s │ %11s │ %10s │\n" % (
        _pad("② 真实吃法(%s %s)" % (_WEEKDAY_CN[weekend_wd], fmt(lunch_weekend)), sc_w),
        fmt(total2), signed(surplus2)))
    out("└%s┴%s┴%s┘\n\n" % ("─" * (sc_w + 2), "─" * 13, "─" * 12))

    if surplus2 >= 0:
        out("结论: PASS ✅  按真实吃法能撑到 %s,结余 %s\n" % (target, signed(surplus2)))
    else:
        out("结论: 不够 ❌  按真实吃法撑不到 %s,缺口 %s\n" % (target, fmt(-surplus2)))

    if show_command:
        out("\n下次可直接跑:\n  %s\n" % equivalent_command(p))
    out("\n")

    return 0 if surplus2 >= 0 else 2


# ---------------------------------------------------------------- 入口

def build_argparser():
    p = argparse.ArgumentParser(
        description="预算检查。无参数直接运行进入交互模式。",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    p.add_argument("--balance", type=str, help="当前余额")
    p.add_argument("--target", type=str, help="目标日期。today / YYYY-MM-DD / MM-DD")
    p.add_argument("--start", type=str, default="today", help="开始日期(两端都算)")
    p.add_argument("--egg-stock-days", type=int, default=None, help="鸡蛋库存还够几天(=下次补货落在第几天)")
    p.add_argument("--milk-stock-days", type=int, default=None, help="牛奶库存还够几天")
    p.add_argument("--ate-lunch-today", action="store_true", help="今天午饭已吃,不计")
    p.add_argument("--paid-gym-today", action="store_true", help="今天(若健身日)已扣,不计")
    p.add_argument("--paid-laundry-today", action="store_true", help="今天(若洗衣日)已付,不计")
    p.add_argument("--phone-paid-this-month", action="store_true", help="本月话费已扣")
    p.add_argument("--apple-paid-this-month", action="store_true", help="本月 Apple 已扣")
    p.add_argument("--claude-code-paid-this-month", action="store_true", help="本月 Claude Code 已扣")
    p.add_argument("--openai-paid-this-month", action="store_true", help="本月 OpenAI 已扣")
    p.add_argument("-i", "--interactive", action="store_true", help="强制进入交互模式")
    p.add_argument("--config", type=str, default=CONFIG_PATH, help="配置文件路径")
    return p


def main():
    parser = build_argparser()
    args = parser.parse_args()

    try:
        cfg, warnings = load_config(args.config)
    except ValueError as e:
        sys.stderr.write("错误: %s\n" % e)
        sys.exit(1)

    # 无 balance/target 或显式 -i → 交互模式
    interactive = args.interactive or (args.balance is None or args.target is None)

    try:
        if interactive:
            params = interactive_flow(cfg)
            code = compute_and_report(cfg, warnings, params, show_command=True)
        else:
            params = params_from_args(args, cfg)
            if params.target < params.start:
                sys.stderr.write("错误: 目标日期 %s 早于开始日期 %s\n" % (params.target, params.start))
                sys.exit(1)
            code = compute_and_report(cfg, warnings, params, show_command=False)
    except ValueError as e:
        sys.stderr.write("错误: %s\n" % e)
        sys.exit(1)
    except KeyboardInterrupt:
        sys.stderr.write("\n已取消。\n")
        sys.exit(130)

    sys.exit(code)


if __name__ == "__main__":
    main()
