--Return to the Deptheavens
local ref,id=GetID()
Duel.LoadScript("Deptheaven.lua")
function ref.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCost(ref.tdcost)
	e1:SetTarget(ref.tdtg)
	e1:SetOperation(ref.tdop)
	c:RegisterEffect(e1)
	--Search
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e,tp) return e:GetHandler():IsPreviousLocation(LOCATION_OVERLAY)
	and Duel.GetFlagEffect(tp,id)==0 end)
	e2:SetCost(ref.thcost)
	e2:SetTarget(ref.thtg)
	e2:SetOperation(ref.thop)
	c:RegisterEffect(e2)
	if not ref.global_check then
		ref.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SSET)
		ge1:SetCondition(function(e,tp,eg) return eg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) end)
		ge1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) Duel.RegisterFlagEffect(rp,id,RESET_PHASE+PHASE_END,0,1) end)
		Duel.RegisterEffect(ge1,0)
	end
end

--Activate
function ref.tdfilter(c) return Deptheaven.Is(c) and c:IsAbleToDeckAsCost() and not c:IsCode(id) end
function ref.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.tdfilter,tp,LOCATION_EXTRA+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) end
	local ct=math.min(Duel.GetMatchingGroupCount(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler()),2)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,ref.tdfilter,tp,LOCATION_EXTRA+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,ct,nil)
	Duel.SendtoDeck(g,nil,2,REASON_COST)
	e:SetLabel(#Duel.GetOperatedGroup())
end
function ref.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsAbleToHand() end
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	local ct=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,c)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function ref.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end

--Search
function ref.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	Duel.Remove(c,POS_FACEUP,REASON_COST)
	Duel.BreakEffect()
	local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	local ct=math.min(hg:GetCount(),2)
	if ct>0 then
		Duel.DiscardHand(tp,aux.TRUE,ct,ct,REASON_COST,nil)
	end
end
function ref.thfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
		and Duel.IsExistingMatchingCard(ref.th2filter,tp,LOCATION_DECK,0,1,c)
end
function ref.th2filter(c) return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToHand() end
function ref.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function ref.thgfilter(g)
	return g:GetClassCount(Card.GetAttribute)==#g
end
function ref.bothfilter(c) return c:IsAttribute(ATTRIBUTE_WATER+ATTRIBUTE_LIGHT) and c:IsAbleToHand() end
function ref.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,ref.bothfilter,tp,LOCATION_DECK,0,1,1,nil)
	local sg=g:SelectSubGroup(tp,ref.thgfilter,false,2,2,tp)
	if sg and Duel.SendtoHand(sg,nil,REASON_EFFECT) then Duel.ConfirmCards(1-tp,sg) end
end
