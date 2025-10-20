#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Oxford 3000 단어 리스트로 기존 JSON 파일들을 업데이트하는 스크립트
"""

import json
import os
from pathlib import Path

# Oxford 3000 단어 리스트 (core_words.json 기반)
OXFORD_WORDS = {
    "conversation": {
        "beginner": ["hello", "yes", "no", "thank", "please", "sorry", "welcome", "bye", "good", "bad", 
                     "help", "talk", "speak", "listen", "ask", "answer", "tell", "say", "name", "meet",
                     "friend", "family", "happy", "sad", "like", "want", "need", "have", "get", "give",
                     "know", "think", "feel", "see", "hear", "come", "go", "eat", "drink", "sleep",
                     "morning", "afternoon", "evening", "night", "today", "tomorrow", "yesterday", "time", "day", "week"],
        "intermediate": ["conversation", "discuss", "explain", "describe", "opinion", "agree", "disagree", 
                        "suggest", "recommend", "advice", "apologize", "compliment", "introduce", "interrupt",
                        "mention", "express", "communicate", "understand", "misunderstand", "clarify",
                        "confirm", "remind", "promise", "refuse", "accept", "reject", "persuade", "argue",
                        "debate", "negotiate", "gossip", "rumor", "whisper", "shout", "mumble", "stutter",
                        "emphasize", "imply", "comment", "remark", "statement", "question", "response",
                        "feedback", "criticism", "praise", "gesture", "expression", "tone", "attitude"],
        "advanced": ["articulate", "eloquent", "rhetoric", "diplomatic", "tactful", "assertive", 
                    "confrontation", "mediation", "reconciliation", "discourse", "dialogue", "monologue",
                    "soliloquy", "vernacular", "colloquial", "jargon", "euphemism", "metaphor", "analogy",
                    "inference", "connotation", "denotation", "ambiguity", "nuance", "subtlety",
                    "implication", "persuasion", "manipulation", "propaganda", "eloquence", "articulation",
                    "deliberation", "contemplation", "rumination", "introspection", "retrospection",
                    "philosophical", "theoretical", "abstract", "conceptual", "hypothetical", "speculative",
                    "intellectual", "cognitive", "analytical", "critical", "rational", "logical"]
    },
    "travel": {
        "beginner": ["trip", "travel", "visit", "go", "come", "arrive", "leave", "stay", "hotel", "room",
                    "airport", "plane", "train", "bus", "taxi", "car", "ticket", "passport", "bag", "luggage",
                    "map", "guide", "tour", "photo", "camera", "beach", "mountain", "city", "country", "place",
                    "food", "restaurant", "shop", "buy", "money", "price", "cheap", "expensive", "book",
                    "reserve", "check", "in", "out", "help", "lost", "find", "where", "when", "how", "far"],
        "intermediate": ["destination", "itinerary", "reservation", "accommodation", "departure", "arrival",
                        "boarding", "customs", "immigration", "security", "baggage", "suitcase", "backpack",
                        "traveler", "tourist", "vacation", "holiday", "adventure", "excursion", "sightseeing",
                        "landmark", "monument", "museum", "gallery", "attraction", "scenic", "hospitality",
                        "reception", "concierge", "amenities", "facilities", "transportation", "schedule",
                        "delay", "cancellation", "refund", "exchange", "currency", "souvenir", "local",
                        "native", "foreign", "international", "domestic", "culture", "tradition", "explore",
                        "discover", "wander", "navigate"],
        "advanced": ["expedition", "pilgrimage", "odyssey", "sojourn", "itinerant", "nomadic", "cosmopolitan",
                    "expatriate", "diaspora", "displacement", "migration", "emigration", "colonization",
                    "exploration", "pioneering", "traversal", "circumnavigation", "embarkation",
                    "disembarkation", "layover", "stopover", "transit", "consulate", "embassy",
                    "jurisdiction", "sovereignty", "territory", "frontier", "boundary", "demarcation",
                    "infrastructure", "logistics", "provisions", "sustenance", "subsistence", "indigenous",
                    "aboriginal", "ethnic", "multicultural", "intercultural", "transnational", "globalization",
                    "acculturation", "assimilation", "adaptation", "orientation", "disorientation", "alienation"]
    },
    "business": {
        "beginner": ["work", "job", "office", "company", "boss", "manager", "worker", "team", "meeting",
                    "email", "call", "phone", "computer", "paper", "pen", "desk", "chair", "file", "document",
                    "report", "money", "pay", "salary", "price", "sell", "buy", "customer", "client",
                    "service", "product", "time", "schedule", "early", "late", "busy", "free", "start",
                    "finish", "break", "lunch", "week", "month", "year", "plan", "goal", "problem",
                    "solution", "help", "thank", "sorry"],
        "intermediate": ["corporation", "enterprise", "organization", "department", "employee", "colleague",
                        "supervisor", "executive", "director", "administrator", "position", "responsibility",
                        "assignment", "project", "deadline", "presentation", "proposal", "contract",
                        "agreement", "negotiation", "transaction", "investment", "profit", "loss", "revenue",
                        "expense", "budget", "finance", "accounting", "marketing", "advertising", "sales",
                        "distribution", "supply", "demand", "inventory", "stock", "quality", "efficiency",
                        "productivity", "performance", "evaluation", "feedback", "promotion", "recruitment",
                        "training", "competition", "strategy", "analysis", "research"],
        "advanced": ["conglomerate", "subsidiary", "affiliate", "merger", "acquisition", "consolidation",
                    "restructuring", "diversification", "specialization", "monopoly", "oligopoly",
                    "entrepreneurship", "venture", "startup", "innovation", "disruption", "transformation",
                    "sustainability", "scalability", "optimization", "automation", "digitalization",
                    "stakeholder", "shareholder", "dividend", "equity", "liability", "asset", "depreciation",
                    "amortization", "valuation", "liquidation", "bankruptcy", "insolvency", "foreclosure",
                    "compliance", "regulation", "legislation", "litigation", "arbitration", "mediation",
                    "intellectual", "proprietary", "patent", "trademark", "copyright", "franchise",
                    "syndicate", "consortium", "collaboration", "partnership", "alliance", "cooperation"]
    },
    "news": {
        "beginner": ["news", "report", "story", "read", "watch", "listen", "tell", "know", "hear", "see",
                    "today", "now", "new", "old", "big", "small", "important", "happen", "event", "thing",
                    "people", "person", "man", "woman", "child", "place", "city", "country", "world", "home",
                    "good", "bad", "right", "wrong", "true", "false", "say", "talk", "speak", "ask", "answer",
                    "think", "believe", "feel", "like", "want", "need", "help", "problem", "change"],
        "intermediate": ["journalism", "reporter", "correspondent", "editor", "publisher", "broadcast",
                        "media", "press", "newspaper", "magazine", "article", "headline", "coverage",
                        "investigation", "interview", "statement", "announcement", "declaration", "disclosure",
                        "revelation", "incident", "occurrence", "development", "situation", "circumstance",
                        "condition", "politics", "government", "election", "policy", "economy", "market",
                        "crisis", "conflict", "dispute", "controversy", "debate", "discussion", "opinion",
                        "perspective", "analysis", "commentary", "criticism", "review", "evaluation",
                        "assessment", "survey", "statistics", "data", "evidence", "proof"],
        "advanced": ["investigative", "editorial", "documentary", "propaganda", "censorship", "freedom",
                    "liberty", "democracy", "autocracy", "totalitarian", "authoritarian", "sovereignty",
                    "jurisdiction", "legislation", "regulation", "constitution", "amendment", "ratification",
                    "referendum", "plebiscite", "electoral", "parliamentary", "congressional", "geopolitical",
                    "diplomatic", "bilateral", "multilateral", "macroeconomic", "microeconomic", "fiscal",
                    "monetary", "inflation", "deflation", "recession", "depression", "prosperity", "austerity",
                    "stimulus", "subsidy", "catastrophe", "calamity", "disaster", "tragedy", "epidemic",
                    "pandemic", "endemic", "humanitarian", "philanthropic", "altruistic", "benevolent",
                    "charitable", "advocacy"]
    }
}

# 한국어 번역 사전
KOREAN_TRANSLATIONS = {
    "hello": "안녕하세요", "yes": "네", "no": "아니요", "thank": "감사하다", "please": "부탁하다",
    "sorry": "미안하다", "welcome": "환영하다", "bye": "안녕", "good": "좋은", "bad": "나쁜",
    "help": "도움", "talk": "말하다", "speak": "말하다", "listen": "듣다", "ask": "묻다",
    "answer": "대답하다", "tell": "말하다", "say": "말하다", "name": "이름", "meet": "만나다",
    "friend": "친구", "family": "가족", "happy": "행복한", "sad": "슬픈", "like": "좋아하다",
    "want": "원하다", "need": "필요하다", "have": "가지다", "get": "얻다", "give": "주다",
    "know": "알다", "think": "생각하다", "feel": "느끼다", "see": "보다", "hear": "듣다",
    "come": "오다", "go": "가다", "eat": "먹다", "drink": "마시다", "sleep": "자다",
    "morning": "아침", "afternoon": "오후", "evening": "저녁", "night": "밤", "today": "오늘",
    "tomorrow": "내일", "yesterday": "어제", "time": "시간", "day": "날", "week": "주",
    "trip": "여행", "travel": "여행하다", "visit": "방문하다", "arrive": "도착하다", "leave": "떠나다",
    "stay": "머물다", "hotel": "호텔", "room": "방", "airport": "공항", "plane": "비행기",
    "train": "기차", "bus": "버스", "taxi": "택시", "car": "차", "ticket": "티켓",
    "passport": "여권", "bag": "가방", "luggage": "짐", "map": "지도", "guide": "가이드",
    "tour": "투어", "photo": "사진", "camera": "카메라", "beach": "해변", "mountain": "산",
    "city": "도시", "country": "나라", "place": "장소", "food": "음식", "restaurant": "레스토랑",
    "shop": "가게", "buy": "사다", "money": "돈", "price": "가격", "cheap": "싼",
    "expensive": "비싼", "book": "예약하다", "reserve": "예약하다", "check": "확인하다",
    "in": "안", "out": "밖", "lost": "잃어버린", "find": "찾다", "where": "어디",
    "when": "언제", "how": "어떻게", "far": "먼", "work": "일", "job": "직업",
    "office": "사무실", "company": "회사", "boss": "상사", "manager": "관리자", "worker": "직원",
    "team": "팀", "meeting": "회의", "email": "이메일", "call": "전화", "phone": "전화기",
    "computer": "컴퓨터", "paper": "종이", "pen": "펜", "desk": "책상", "chair": "의자",
    "file": "파일", "document": "문서", "report": "보고서", "pay": "지불하다", "salary": "급여",
    "sell": "팔다", "customer": "고객", "client": "클라이언트", "service": "서비스", "product": "제품",
    "schedule": "일정", "early": "이른", "late": "늦은", "busy": "바쁜", "free": "자유로운",
    "start": "시작하다", "finish": "끝내다", "break": "휴식", "lunch": "점심", "month": "월",
    "year": "년", "plan": "계획", "goal": "목표", "problem": "문제", "solution": "해결책",
    "news": "뉴스", "story": "이야기", "read": "읽다", "watch": "보다", "now": "지금",
    "new": "새로운", "old": "오래된", "big": "큰", "small": "작은", "important": "중요한",
    "happen": "일어나다", "event": "사건", "thing": "것", "people": "사람들", "person": "사람",
    "man": "남자", "woman": "여자", "child": "아이", "world": "세계", "home": "집",
    "right": "옳은", "wrong": "틀린", "true": "진실", "false": "거짓", "believe": "믿다",
    "change": "변화", "conversation": "대화", "discuss": "논의하다", "explain": "설명하다",
    "describe": "묘사하다", "opinion": "의견", "agree": "동의하다", "disagree": "동의하지 않다",
    "suggest": "제안하다", "recommend": "추천하다", "advice": "조언", "apologize": "사과하다",
    "compliment": "칭찬", "introduce": "소개하다", "interrupt": "방해하다", "mention": "언급하다",
    "express": "표현하다", "communicate": "소통하다", "understand": "이해하다", "misunderstand": "오해하다",
    "clarify": "명확히 하다", "confirm": "확인하다", "remind": "상기시키다", "promise": "약속하다",
    "refuse": "거절하다", "accept": "받아들이다", "reject": "거부하다", "persuade": "설득하다",
    "argue": "논쟁하다", "debate": "토론하다", "negotiate": "협상하다", "gossip": "소문",
    "rumor": "소문", "whisper": "속삭이다", "shout": "소리치다", "mumble": "중얼거리다",
    "stutter": "말을 더듬다", "emphasize": "강조하다", "imply": "암시하다", "comment": "논평하다",
    "remark": "발언", "statement": "성명", "question": "질문", "response": "응답",
    "feedback": "피드백", "criticism": "비판", "praise": "칭찬", "gesture": "몸짓",
    "expression": "표현", "tone": "어조", "attitude": "태도"
}

# 품사 매핑
POS_MAPPING = {
    "hello": "interjection", "yes": "interjection", "no": "interjection", "thank": "verb",
    "please": "adverb", "sorry": "adjective", "welcome": "verb", "bye": "interjection",
    "good": "adjective", "bad": "adjective", "help": "verb", "talk": "verb", "speak": "verb",
    "listen": "verb", "ask": "verb", "answer": "verb", "tell": "verb", "say": "verb",
    "name": "noun", "meet": "verb", "friend": "noun", "family": "noun", "happy": "adjective",
    "sad": "adjective", "like": "verb", "want": "verb", "need": "verb", "have": "verb",
    "get": "verb", "give": "verb", "know": "verb", "think": "verb", "feel": "verb",
    "see": "verb", "hear": "verb", "come": "verb", "go": "verb", "eat": "verb",
    "drink": "verb", "sleep": "verb", "morning": "noun", "afternoon": "noun", "evening": "noun",
    "night": "noun", "today": "adverb", "tomorrow": "adverb", "yesterday": "adverb",
    "time": "noun", "day": "noun", "week": "noun"
}

def get_korean_translation(word):
    """단어의 한국어 번역을 반환"""
    return KOREAN_TRANSLATIONS.get(word, word)

def get_pos(word):
    """단어의 품사를 반환"""
    return POS_MAPPING.get(word, "noun")

def create_word_entry(word, level, category):
    """단어 항목 생성"""
    return {
        "word": word,
        "meaning_ko": get_korean_translation(word),
        "pos": get_pos(word),
        "example": f"This is an example with {word}.",
        "level": level,
        "category": category
    }

def update_json_files():
    """모든 JSON 파일 업데이트"""
    base_path = Path(__file__).parent.parent / "assets" / "data"
    
    # 레벨 매핑
    level_mapping = {
        "beginner": "기초다지기",
        "intermediate": "표현력확장",
        "advanced": "원어민수준"
    }
    
    # 카테고리 매핑
    category_mapping = {
        "conversation": "일상회화",
        "travel": "여행",
        "business": "비즈니스",
        "news": "뉴스-시사"
    }
    
    print("Oxford 3000 단어로 JSON 파일 업데이트 시작...")
    
    for category_en, category_ko in category_mapping.items():
        for level_en, level_ko in level_mapping.items():
            # 영어 파일
            en_filename = f"EN_{level_ko}_{category_ko}.json"
            en_filepath = base_path / en_filename
            
            # 한국어 파일
            ko_filename = f"KO_{level_ko}_{category_ko}.json"
            ko_filepath = base_path / ko_filename
            
            # 단어 리스트 가져오기
            words = OXFORD_WORDS.get(category_en, {}).get(level_en, [])
            
            if not words:
                print(f"⚠️  {category_en}/{level_en}에 대한 단어가 없습니다.")
                continue
            
            # 영어 파일 생성
            en_data = []
            for word in words:
                en_data.append(create_word_entry(word, level_ko, category_ko))
            
            with open(en_filepath, 'w', encoding='utf-8') as f:
                json.dump(en_data, f, ensure_ascii=False, indent=2)
            
            print(f"✅ {en_filename} 업데이트 완료 ({len(en_data)}개 단어)")
            
            # 한국어 파일 생성 (동일한 구조)
            with open(ko_filepath, 'w', encoding='utf-8') as f:
                json.dump(en_data, f, ensure_ascii=False, indent=2)
            
            print(f"✅ {ko_filename} 업데이트 완료 ({len(en_data)}개 단어)")
    
    print("\n모든 파일 업데이트 완료! 🎉")

if __name__ == "__main__":
    update_json_files()

