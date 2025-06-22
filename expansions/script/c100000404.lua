--[[
Unknown HERO Network
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.RegisterCustomArchetype(id,CUSTOM_ARCHE_UNKNOWN_HERO)
	c:EnableCounterPermit(COUNTER_FAVOR)
	--You can only control 1 "Unknown HERO Network". 
	c:SetUniqueOnField(1,0,id)
	--When this card is activated: You can add 1 "Unknown HERO" monster from your Deck or GY to your hand.
	local e1=c:Activation(true,nil,nil,nil,s.target,s.activate,true)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_SEARCH|CATEGORY_GRAVE_ACTION)
	c:RegisterEffect(e1)
	--Once per turn: You can target cards in your GY, up to the number of "HERO" monsters you control with different original names; shuffle those targets into the Deck, and if you do, place 1 Favor Counter on this card for every 2 cards shuffled into the Deck this way, rounded down.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TODECK|CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:OPT()
	e2:SetCost(aux.InfoCost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
	--Once per turn: You can remove Favor Counters from this card in multiples of 2 (max. 6); add 1 card from your Deck to your hand for every 2 Favor Counters removed this way (any combination of "HERO" monsters, "Fusion" Spell Cards, and/or "Unknown HERO" cards, except "Unknown HERO Network").
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetCategory(CATEGORIES_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:OPT()
	e3:SetCost(aux.InfoCost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thfilter(c)
	return c:IsMonster() and c:IsCustomArchetype(CUSTOM_ARCHE_UNKNOWN_HERO) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.Necro(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,nil)
	if #g==0 or not Duel.SelectYesNo(tp,STRING_ASK_SEARCH) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tg=g:Select(tp,1,1,nil)
	if #tg>0 then
		Duel.Search(tg)
	end
end

--E2
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_HERO)
end
function s.tdfilter(c,e)
	return c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc:IsAbleToDeck() end
	local g=Duel.Group(s.tdfilter,tp,LOCATION_GRAVE,0,nil,e)
	local ct=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil):GetClassCount(Card.GetOriginalCodeRule)
	if chk==0 then
		return ct>0 and #g>0
	end
	local c=e:GetHandler()
	ct=math.min(ct,#g)
	if ct>=2 then
		for i=math.floor(ct/2),1,-1 do
			if c:IsCanAddCounter(COUNTER_FAVOR,i) then
				ct=math.min(ct,i*2+1)
				break
			end
		end
	end
	Duel.HintMessage(tp,HINTMSG_TODECK)
	local tg=g:Select(tp,1,ct,nil)
	Duel.SetTargetCard(tg)
	Duel.SetCardOperationInfo(tg,CATEGORY_TODECK)
	if #tg>1 then
		Duel.SetOperationInfo(0,CATEGORY_COUNTER,c,1,tp,COUNTER_FAVOR)
	end
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards():Filter(Card.IsControler,nil,tp)
	if #g>0 and Duel.ShuffleIntoDeck(g)>0 then
		local c=e:GetHandler()
		local ct=Duel.GetGroupOperatedByThisEffect(e):FilterCount(Card.IsLocation,nil,LOCATION_DECK|LOCATION_EXTRA)
		if ct>=2 and c:IsRelateToChain() and c:IsFaceup() then
			c:AddCounter(COUNTER_FAVOR,math.floor(ct/2),true)
		end
	end
end

--E3
function s.thfilter(c)
	if c:IsCode(id) or not c:IsAbleToHand() then return false end
	return (c:IsMonster() and c:IsSetCard(ARCHE_HERO))
		or (c:IsSpell() and c:IsSetCard(ARCHE_FUSION))
		or c:IsCustomArchetype(CUSTOM_ARCHE_UNKNOWN_HERO)
end
function s.check(c,ct)
	return	function(i,p)
				return c:IsCanRemoveCounter(tp,COUNTER_FAVOR,i,REASON_COST) and ct>=i/2
			end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.Group(s.thfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then
		return e:IsCostChecked() and c:IsCanRemoveCounter(tp,COUNTER_FAVOR,2,REASON_COST) and #g>0
	end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	local ct=Duel.AnnounceNumberMinMax(tp,2,6,s.check(c,#g),2)
	c:RemoveCounter(tp,COUNTER_FAVOR,ct,REASON_COST)
	Duel.SetTargetParam(ct/2)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,ct/2,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetTargetParam()
	if not ct then return end
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,ct,ct,nil)
	if #g>0 then
		Duel.Search(g)
	end
end