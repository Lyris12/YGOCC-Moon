--[[
Swords Bestowed By the Seven Billion Shining Stars
Spade Dispensate Dalle Sette Miliardi di Stelle Sfavillanti
Card Author: ohmyhowswaggy
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id-1)
	--Activation
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetLabel(0)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(s.eqlimit)
	c:RegisterEffect(e2)
	--The equipped monster gains 700 ATK for each Equip Spell equipped to it, and cannot be targeted by your opponent's card effects.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
	--[[You can discard this card; excavate the top 7 cards of your Deck, and if you do, send all excavated Equip Spells to the GY, and return the rest to the bottom of your Deck in any order.]]
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_TOGRAVE|CATEGORY_DECKDES)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:HOPT()
	e5:SetRange(LOCATION_HAND)
	e5:SetCost(s.exccost)
	e5:SetTarget(s.exctg)
	e5:SetOperation(s.excop)
	c:RegisterEffect(e5)
	--[[If this card is sent from the hand or field to the GY to activate the effect of "Sword Saint Sovereign of the Solemn Star Sea":
	You can target 1 "Sword Saint Sovereign of the Solemn Star Sea" you control; equip this card to it.]]
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,3))
	e6:SetCategory(CATEGORY_EQUIP)
	e6:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:HOPT()
	e6:SetLabel(1)
	e6:SetCondition(s.eqcon)
	e6:SetTarget(s.target)
	e6:SetOperation(s.activate)
	c:RegisterEffect(e6)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
function s.counterfilter(c)
	return c:IsRace(RACE_WARRIOR)
end

--E1
function s.filter(c,ec)
	return c:IsFaceup() and c:IsCode(id-1) and ec:CheckEquipTarget(c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,c) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,c)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
	if e:GetLabel()==1 then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and tc:IsRelateToChain() and tc:IsFaceup() then
		Duel.Equip(tp,c,tc)
	end
end

--E2
function s.eqlimit(e,c)
	return c:IsCode(id-1)
end

--E3
function s.atkval(e,c)
	local g=c:GetEquipGroup()
	if not g then return 0 end
	return g:FilterCount(aux.FaceupFilter(Card.IsSpell,TYPE_EQUIP),nil)*700
end

--E5
function s.exccost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT|EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	Duel.SendtoGrave(c,REASON_COST|REASON_DISCARD)
end
function s.splimit(e,c)
	return not c:IsRace(RACE_WARRIOR)
end
function s.excfilter(c)
	return c:IsSpell(TYPE_EQUIP) and c:IsAbleToGrave()
end
function s.exctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanDiscardDeck(tp,7)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.excop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPlayerCanDiscardDeck(tp,7) then return end
	Duel.ConfirmDecktop(tp,7)
	local g=Duel.GetDecktopGroup(tp,7)
	local sg=g:Filter(s.excfilter,nil)
	if #sg>0 then
		Duel.DisableShuffleCheck()
		Duel.SendtoGrave(sg,REASON_EFFECT|REASON_REVEAL)
	end
	Duel.SortDecktop(tp,tp,7-#sg)
	for i=1,7-#sg do
		local mg=Duel.GetDecktopGroup(tp,1)
		Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
	end
end

--E6
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsReason(REASON_COST) and c:IsPreviousLocation(LOCATION_HAND|LOCATION_ONFIELD) and re:IsActivated()) then return false end
	local code1,code2=Duel.GetChainInfo(Duel.GetCurrentChain(),CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2)
	return code1==id-1 or (code2 and code2==id-1)
end