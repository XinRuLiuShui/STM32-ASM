# 工具链
AS      = arm-none-eabi-as
LD      = arm-none-eabi-ld
OBJCOPY = arm-none-eabi-objcopy

# CPU
CPU = cortex-m3

# 目录
BUILD = build

# 最终文件
ELF = $(BUILD)/main.elf
BIN = $(BUILD)/main.bin

# 目标
all: $(BIN)

# .bin 由 .elf 生成
$(BIN): $(ELF)
	$(OBJCOPY) -O binary $< $@

# .elf 由两个 .o 文件链接
$(ELF): $(BUILD)/startup.o $(BUILD)/main.o
	$(LD) -T linker.ld $^ -o $@

# startup.s -> startup.o
$(BUILD)/startup.o: startup.s
	mkdir -p $(BUILD)
	$(AS) -mcpu=$(CPU) -mthumb $< -o $@

# main.s -> main.o
$(BUILD)/main.o: main.s
	mkdir -p $(BUILD)
	$(AS) -mcpu=$(CPU) -mthumb $< -o $@

# 删除编译结果
clean:
	rm -rf $(BUILD)

flash: $(BIN)
	st-flash write $(BIN) 0x08000000

.PHONY: all clean
