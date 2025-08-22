# stm32-led-toggle

Projeto em Assembly para STM32F4 (Cortex-M4) que demonstra:
- Configuração de GPIOs para LEDs (PA0, PA1, PA4, PA5, PA6, PA7).
- Leitura de botão no pino PC13.
- Implementação de debounce por software.
- Alternância (toggle) do estado dos LEDs a cada clique válido no botão.

## 🛠 Requisitos

- **MCU**: STM32F4 (ex: STM32F407 Discovery)
- **Compilador**: arm-none-eabi-as / arm-none-eabi-gcc
- **Ferramentas de upload/debug**: OpenOCD, ST-Link Utility ou equivalente
- **Ambiente**: Linux, Windows ou WSL

## 📂 Estrutura do código

- `.text` → contém o código principal (função `main` com laço infinito).
- `.data` → contém variáveis para debounce (`debounce_count`, `last_state`, `DEBOUNCE_THRESHOLD`).

## ⚙️ Funcionamento

1. O clock dos periféricos **GPIOA** e **GPIOC** é habilitado.
2. Os pinos **PA0, PA1, PA4, PA5, PA6, PA7** são configurados como saída e usados para LEDs.
3. O pino **PC13** é configurado como entrada (botão).
4. A cada pressão de botão estável (após passar no filtro de debounce), os LEDs alternam entre ligados e desligados.
5. O loop principal garante a leitura contínua do botão e atualização dos LEDs.

## 🚀 Compilação e Upload

### Compilar
```sh
arm-none-eabi-as -mcpu=cortex-m4 -mthumb main.s -o main.o
arm-none-eabi-ld main.o -Ttext=0x08000000 -o main.elf
arm-none-eabi-objcopy -O binary main.elf main.bin
