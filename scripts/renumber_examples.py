#!/usr/bin/env python3
"""
텍스트 파일의 예문 넘버링을 파일별에서 전체 넘버링으로 변경하는 스크립트
"""

import re
from pathlib import Path

def renumber_examples(input_file, output_file):
    """
    텍스트 파일의 예문 넘버링을 전체 넘버링으로 변경
    
    Args:
        input_file (str): 입력 텍스트 파일 경로
        output_file (str): 출력 텍스트 파일 경로
    """
    
    with open(input_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    # 새로운 내용을 저장할 리스트
    new_lines = []
    example_counter = 1
    
    for line in lines:
        # 예문 라인인지 확인 (숫자로 시작하고 점이 있는 패턴)
        if re.match(r'^\s*\d+\.\s+', line):
            # 기존 번호를 제거하고 새로운 번호로 교체
            # "  1. " 또는 "1. " 같은 패턴을 찾아서 교체
            new_line = re.sub(r'^\s*\d+\.\s+', f'{example_counter:3d}. ', line)
            new_lines.append(new_line)
            example_counter += 1
        else:
            # 예문이 아닌 라인은 그대로 유지
            new_lines.append(line)
    
    # 새로운 파일에 저장
    with open(output_file, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)
    
    print(f"✅ 완료: {input_file} -> {output_file}")
    print(f"총 {example_counter - 1}개의 예문이 전체 넘버링으로 변경되었습니다.")

def main():
    """메인 함수"""
    # 파일 경로 설정
    project_root = Path(__file__).parent.parent
    input_file = project_root / "all_ko_examples.txt"
    output_file = project_root / "all_ko_examples_renumbered.txt"
    
    if not input_file.exists():
        print(f"❌ 입력 파일을 찾을 수 없습니다: {input_file}")
        return
    
    print(f"입력 파일: {input_file}")
    print(f"출력 파일: {output_file}")
    print("=" * 50)
    
    renumber_examples(input_file, output_file)
    
    # 원본 파일을 새 파일로 교체
    print("\n원본 파일을 새 파일로 교체합니다...")
    input_file.unlink()  # 원본 파일 삭제
    output_file.rename(input_file)  # 새 파일을 원본 이름으로 변경
    
    print(f"✅ 최종 완료: {input_file}")

if __name__ == "__main__":
    main()
