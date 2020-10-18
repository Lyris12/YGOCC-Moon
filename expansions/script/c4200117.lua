--Blazing Blue Gem - Marine Godspark
--Created and Scripted by Swaggy
local m=4200117
local cm=_G["c"..m]
function cm.initial_effect(c)
	--D-Draw
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,m+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
	--Race-based Milling
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,m+100)
	e2:SetCondition(cm.milcon)
	e2:SetTarget(cm.miltg)
	e2:SetOperation(cm.milop)
	c:RegisterEffect(e2)
	--Recovery.tm
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,m+200)
	e3:SetCondition(cm.thcon)
	e3:SetTarget(cm.thtg)
	e3:SetOperation(cm.thop)
	c:RegisterEffect(e3)
end
function cm.cfilter(c)
	return c:IsSetCard(0x412) and c:IsDiscardable()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if Duel.IsPlayerCanDraw(tp,2) and Duel.IsExistingMatchingCard(cm.cfilter,tp,LOCATION_HAND,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(m,0)) then
		e:SetCategory(CATEGORY_DRAW)
		e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e:SetOperation(cm.activate)
		if Duel.DiscardHand(tp,cm.cfilter,1,1,REASON_COST+REASON_DISCARD)>0 then
			Duel.SetTargetPlayer(tp)
			Duel.SetTargetParam(2)
			Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
		end
	else
		e:SetCategory(0)
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function cm.seqcfilter(c,tp)
   return c:IsFaceup() and c:IsSetCard(0x412) and c:IsType(TYPE_MONSTER) and c:IsControler(tp)
end
function cm.milfilter(c,g)
	return c:IsSetCard(0x412) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
		and not g:IsExists(cm.classfilter,1,c,c:GetRace(),c:GetAttribute())
end
function cm.classfilter(c,race,attr)
	return c:IsRace(race) or c:IsAttribute(attr)
end
function cm.milcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.seqcfilter,1,nil,tp)
end
function cm.miltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local sg=eg:Filter(cm.seqcfilter,nil,tp)
	if chk==0 then return #sg>0 and Duel.IsExistingMatchingCard(cm.milfilter,tp,LOCATION_DECK,0,1,nil,sg) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function cm.milop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local sg=eg:Filter(cm.seqcfilter,nil)
	if #sg<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,cm.milfilter,tp,LOCATION_DECK,0,1,1,nil,sg)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
function cm.thfilter(c,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsSetCard(0x412)
		and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function cm.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.thfilter,1,nil,tp)
end
function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(cm.thfilter,nil,tp)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function cm.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local rg=g:Select(tp,1,1,nil)
	if rg:GetCount()>0 then
		Duel.SendtoHand(rg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,rg)
	end
end