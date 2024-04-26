
let lastSelectedCategory;
let neededEXP = null;
let maxLevel = null;
let currentLevel = null;
let currentXP = null;
let firstOpen = true;
let devmode = false;
let openedtab = "";
let categories = [];
let items = [];
let translation = null;

window.addEventListener("message", function (event) {
  switch (event.data.type) {
    case "show":
      if (firstOpen) {
        firstOpen = false;
        categories = event.data.categories;
        items = event.data.items;
        inventory = event.data.inventory;
        neededEXP = event.data.neededxp;
        maxLevel = event.data.maxlvl;
        translation = event.data.translation;
        giveExp(event.data.currentXP);
        setCategories(categories);

        $(".title1").html(translation.title);
        $(".title2").html(translation.title2);
        $(".category_list_title").html(translation.categories);
        $('#inputBox').attr('placeholder', translation.search);
        $(".crafting_needed_label").html(translation.itemsneeded);
        $(".crafting_time_label").html(translation.crafttime);
        $(".crafting_count_label").html(translation.craftcount);
        $(".craft_button").html(translation.craft);
        $(".bottom_right_top_title").html(translation.craftingqueue);
        $(".bottom_right_top_desc").html(translation.craftingqueuedesc);
      }
      giveExp(event.data.currentXP);
      inventory = event.data.inventory;

      $(".item_window:first-child").click();
      crafting_number(1);
      setTimeout(() => {
        crafting_number(-1);
      }, 50);

      setTimeout(() => {
        $(".main").css("display", "flex");
      }, 200);
      break;
    case "LoadConfig":
      devmode = event.data.devmode;
      break;
  }
})



function updatecounters() {
  if (currentXP >= neededEXP) {
    currentLevel += Math.floor(currentXP / neededEXP);
    currentXP = currentXP % neededEXP;
  }
  setTimeout(() => {
    currentXP = currentLevel > maxLevel ? neededEXP : currentXP;
    currentLevel = currentLevel > maxLevel ? maxLevel : currentLevel;
    $(".profile_level_levelcount").html(translation.level + currentLevel);
    $(".profile_level_progress").css("width", (currentXP / neededEXP) * 100 + "%");
    $(".profile_level_xpcount").html(currentXP + "/" + neededEXP + " XP");
  }, 100);
}

function giveExp(number) {
  currentLevel = 0;
  currentXP = 0;
  currentXP += number;
  updatecounters();
}

$(document).on("keydown", function () {
  switch (event.keyCode) {
    case 27: // ESC
      $.post(`https://${GetParentResourceName()}/closeMenu`, JSON.stringify());
      $(".bg_image").css("display", "none");
      setTimeout(() => {
        $(".main").css("display", "none");
      }, 200);
      break;
  }
});


function setCategories(data) {
  $(".category_items").empty();
  data.forEach((element) => {
    $(".category_items").append(`
      <div class="category_item" id="${element.id}">
        <div class="category_item_label">${element.label}</div>
      </div>
    `);
  });

  setTimeout(() => {
    lastSelectedCategory = data[0];
    $(".category_item:first-child").click();
    $(".item_window:first-child").click();
  }, 1);
}

$(document).on("click", ".category_item", function () {
  let $this = $(this);

  $(".category_item.active").removeClass("active");
  $this.addClass("active");
  setItemsIntoCategory(items, $this.attr("id"));
});


function setItemsIntoCategory(data, cate) {
  lastSelectedCategory = cate;
  $(".items_list").empty();

  data.sort((a, b) => a.level - b.level);

  data.forEach((element) => {
    if (element.category === cate) {
      const isAvailable = currentLevel >= element.level;
      const availabilityClass = isAvailable ? "" : "unavailable";

      const html = `
        <div class="item_window ${availabilityClass}" id="${element.id_item}">
          <div class="item_window_left">
            <div class="item_window_icon">
              <img src="nui://ox_inventory/web/images/${element.respname}.png">
            </div>
          </div>
          <div class="item_window_right">
            <div class="item_window_right_label">${element.label}</div>
            <div class="item_window_right_category">${element.type}</div>
            <div class="item_window_right_stats">
              <div class="item_window_right_time">${element.time}s</div>
              <div class="item_window_right_lvl">${element.level}.lvl</div>
            </div>
          </div>
        </div>
      `;
      $(".items_list").append(html);
    }
  });
}

$(document).ready(function () {
  $("#inputBox").on("input", function () {
    var searchText = $(this).val().toLowerCase();

    $(".item_window").each(function () {
      var label = $(this).find(".item_window_right_label").text().toLowerCase();
      $(this).toggle(label.includes(searchText));
    });
  });
});

$(document).on("click", ".item_window:not(.unavailable):not(.active)", function () {
  $(".item_window").removeClass("active");
  $(this).addClass("active");
  let id = $(this).attr("id");
  let idtosend = parseInt(id);
  setItemsIntoInformation(idtosend);
  setCraftButton(idtosend)
  $("#currentNumber").text(1);
});

function setItemsIntoInformation(id_item) {

  let Item_tocraft = parseInt(id_item);
  let foundItem = items.find(item => item.id_item === Item_tocraft);

  if (foundItem) {
    $(".crafting_item").attr("src", "nui://ox_inventory/web/images/" + foundItem.respname + ".png");
    $(".crafting_label").text(foundItem.label);
    $(".crafting_class").text(foundItem.type);
    $(".crafting_desc").html(foundItem.desc);

    $(".crafting_needed_list").empty();

    foundItem.required_items.forEach(requiredItem => {
      const isInInventory = checkIfItemInInventory(requiredItem.item, requiredItem.count, inventory);
      const itemClass = isInInventory ? '' : 'doesnothave';
      const html = `
        <div class='crafting_needed_item ${itemClass}'>
          <div class='crafting_needed_left'>
            <div class='crafting_needed_icon'>
              <img src='nui://ox_inventory/web/images/${requiredItem.item}.png'>
            </div>
          </div>
          <div class='crafting_needed_right'>
            <div class='crafting_needed_item_label'>${requiredItem.label}</div>
            <div class='crafting_needed_item_count' data-item='${requiredItem.item}'>${requiredItem.count}x</div>
          </div>
        </div>
      `;

      $(".crafting_needed_list").append(html);
    });

    $(".crafting_timing").text(foundItem.time + "s");
    $(".crafting_counting").text(foundItem.count + "x");
  } else {
    log(`No data available for the specified id_item: ${Item_tocraft}.`, "err");
  }
}

function checkIfItemInInventory(itemName, requiredCount, inventory_received) {
  try {
    const inventoryArray = Array.isArray(inventory_received) ? inventory_received : JSON.parse(inventory_received);

    const foundItem = inventoryArray.find(item => item.name === itemName);

    if (foundItem && foundItem.amount >= requiredCount) {
      log(`${foundItem.name} is in the inventory with a quantity of ${foundItem.amount}; required quantity: ${requiredCount}.`, "info");
      return true;
    } else {
      log(`Item named ${itemName} not found in inventory or the quantity is insufficient.`, "err");
      return false;
    }
  } catch (error) {
    log(`ERROR: ${error}`, "err");
    return false;
  }
}

$(document).ready(function () {
  $(".crafting_number_button_minus").click(function () {
    crafting_number(-1);
  });
  $(".crafting_number_button_plus").click(function () {
    crafting_number(1);
  });
});

function crafting_number(amount) {
  let counting = parseInt($(".crafting_counting").text());
  let timing = parseInt($(".crafting_timing").text());
  let currentNumber = parseInt($(".crafting_number").text());

  let newNumber = Math.max(1, currentNumber + amount);
  counting = counting / currentNumber * newNumber;
  timing = timing / currentNumber * newNumber;

  let insufficientItems = [];

  $(".crafting_needed_item_count").each(function () {
    let textContent = $(this).text();
    let neededItemCount = parseInt(textContent.slice(0, -1));
    let updatedCount = Math.round(neededItemCount / currentNumber * newNumber);
    $(this).text(updatedCount + "x");

    const itemName = $(this).data('item');
    const foundItem = inventory.find(item => item.name === itemName);

    const $craftingItem = $(this).closest('.crafting_needed_item');
    if (foundItem) {
      if (updatedCount > foundItem.amount) {
        $craftingItem.addClass('doesnothave');
        insufficientItems.push(itemName);
      } else {
        $craftingItem.removeClass('doesnothave');
      }
    } else {
      $craftingItem.addClass('doesnothave');
    }
  });

  insufficientItems.forEach(itemNameToCheck => {
    const $insufficientItem = $(`.crafting_needed_item_count[data-item='${itemNameToCheck}']`);
    $insufficientItem.closest('.crafting_needed_item').addClass('doesnothave');
  });

  $(".crafting_counting").text(counting + "x");
  $(".crafting_timing").text(timing + "s");
  $(".crafting_number").text(newNumber);
}



function canCraft() {
  let canCraftFlag = true;

  $(".crafting_needed_item").each(function () {
    if ($(this).hasClass('doesnothave')) {
      canCraftFlag = false;
      return false;
    }
  });

  return canCraftFlag;
}

function setCraftButton(id_item) {
  let Item_toqueue = parseInt(id_item);
  let isCraftingCooldown = false;

  $(document).off("click", ".craft_button");
  $(document).on("click", ".craft_button", function () {
    if (canCraft() && !isCraftingCooldown) {
      isCraftingCooldown = true;

      let itemData = items.find(item => item.id_item === Item_toqueue);
      if (itemData) {
        let timing = parseInt($(".crafting_timing").text());
        let progressBarId = "odliczanie_" + Date.now();

        let craftingQueueItem = `
          <div class="crafting_queue_item">
            <div class="crafting_queue_icon">
              <img src="nui://ox_inventory/web/images/${itemData.respname}.png">
            </div>
            <div class="crafting_queue_right">
              <div class="crafting_queue_label">${itemData.label}</div>
              <div class="crafting_queue_timer" id="${progressBarId}_timer">${timing}s</div>
            </div>
            <div class="crafting_queue_progressbar" id="${progressBarId}"></div>
          </div>
        `;

        $(".crafting_queue_list").append(craftingQueueItem);

        startCraftingTimer(timing, progressBarId);
        let requireditem_resp_array = [];
        let requireditem_count_array = [];

        $('.crafting_needed_item_count').each(function () {
          const requireditem_resp = $(this).data('item');
          const requireditem_count_text = $(this).text();
          const requireditem_count = parseInt(requireditem_count_text, 10);
          requireditem_resp_array.push(requireditem_resp);
          requireditem_count_array.push(requireditem_count);
        });

        let craftingTimingArray = [];

        $('.crafting_timing').each(function () {
          const craftingTimingValue = $(this).text();
          const numericValue = parseInt(craftingTimingValue.slice(0, -1), 10);

          craftingTimingArray.push(numericValue);
        });

        let craftingCountingValue = 0;

        $('.crafting_counting').each(function () {
          const currentCountingValue = parseInt($(this).text().slice(0, -1), 10);

          if (!isNaN(currentCountingValue)) {
            craftingCountingValue += currentCountingValue;
          }
        });

        $.post(
          `https://${GetParentResourceName()}/craftitem`,
          JSON.stringify({
            requireditemResp: requireditem_resp_array,
            requireditemCount: requireditem_count_array,
          }),
          function (data) {
            if (data) {
              $.post(`https://${GetParentResourceName()}/closeMenu`, JSON.stringify());
              $(".bg_image").css("display", "none");
              setTimeout(() => {
                $(".main").hide(200);
                $(".crafting_queue_list").show(0);

              }, 200);
              setTimeout(() => {
                $.post(`https://${GetParentResourceName()}/additem`, JSON.stringify({
                  itemResp: itemData.respname,
                  itemCount: craftingCountingValue,
                }));
              }, craftingTimingArray * 1000);
            }
          }
        );

        setTimeout(() => {
          isCraftingCooldown = false;
        }, 2000);
      } else {
        log(`No data available for the specified id_item: ${id_item}`, "warning");
        isCraftingCooldown = false;
      }
    } else {
      log("You cannot start crafting - required items are missing or cooldown is in effect.", "warning");
    }
  });
}

function startCraftingTimer(seconds, progressBarId) {
  let timerElement = $(`#${progressBarId}_timer`);
  let craftingQueueItem = $(`#${progressBarId}`).closest('.crafting_queue_item');

  let progressBar = new ProgressBar.Circle(`#${progressBarId}`, {
    strokeWidth: 10,
    duration: seconds * 1000,
    color: "#00ffd2",
    trailColor: "rgba(25, 29, 39, 0.97)",
    trailWidth: 5,
  });

  let countdownInterval = setInterval(function () {
    seconds--;

    if (seconds >= 0) {
      timerElement.text(seconds + "s");
    } else {
      clearInterval(countdownInterval);
      timerElement.text(translation.crafted);
      setTimeout(() => {
        craftingQueueItem.fadeOut(500, function () {
          progressBar.destroy();
          $(this).remove();
        });
      }, 15000);
    }
  }, 1000);

  progressBar.animate(1, {
    duration: seconds * 1000,
  });
}

function log(message, logType = "info") {
  const logTypes = {
    info: "^5[koja-crafting]^0 ^4[INFO]^0 ",
    done: "^5[koja-crafting]^0 ^2[DONE]^0 ",
    err: "^5[koja-crafting]^0 ^1[ERROR]^0 ",
    warning: "^5[koja-crafting]^0 ^3[WARNING]^0 ",
  };
  const resetColor = "^0";

  if (devmode === true) {
    console.log(`${logTypes[logType]}${message}${resetColor}`);
  }
}
