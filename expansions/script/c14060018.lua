--挽魂的影魔
local m=14060018
local cm=_G["c"..m]
function cm.initial_effect(c)
	Duel.EnableGlobalFlag(GLOBALFLAG_DECK_REVERSE_CHECK)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
	--to deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,0))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetTarget(cm.rettg)
	e2:SetOperation(cm.retop)
	c:RegisterEffect(e2)
	--Destroy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(m,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_TODECK)
	e3:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_DECK)
	e3:SetCountLimit(1)
	e3:SetCondition(cm.tgcon)
	e3:SetTarget(cm.destg)
	e3:SetOperation(cm.desop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SPSUMMON_PROC_G)
	e4:SetRange(LOCATION_DECK)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCondition(cm.tgcon)
	c:RegisterEffect(e4)
end
function cm.spfilter(c,e,tp)
	return c:IsSetCard(0x1406) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and (Duel.GetLocationCountFromEx(tp)>0 or not c:IsLocation(LOCATION_EXTRA))
end
function cm.cfilter(c,e,tp)
	return (c:IsSetCard(0x1406) or (c:IsFacedown() and c:IsLocation(LOCATION_MZONE))) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave() and not c:IsImmuneToEffect(e) and Duel.IsExistingMatchingCard(cm.cfilter1,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,c)
end
function cm.cfilter1(c)
	return (c:IsSetCard(0x1406) or (c:IsFacedown() and c:IsLocation(LOCATION_MZONE))) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		loc=LOCATION_HAND+LOCATION_ONFIELD
	else
		loc=LOCATION_ONFIELD
	end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:CancelToGrave()
		if Duel.SendtoDeck(c,nil,2,REASON_EFFECT) and Duel.IsExistingMatchingCard(cm.cfilter,tp,loc,0,1,nil,e,tp) and Duel.IsExistingMatchingCard(cm.spfilter,tp,LOCATION_EXTRA+LOCATION_DECK,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(m,2)) then
			Duel.BreakEffect()
			local g=Duel.SelectMatchingCard(tp,cm.cfilter,tp,loc,0,1,1,nil,e,tp)
			local g1=Duel.SelectMatchingCard(tp,cm.cfilter1,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,99,g)
			g:Merge(g1)
			if Duel.SendtoGrave(g,REASON_EFFECT)~=0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local g=Duel.SelectMatchingCard(tp,cm.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
				if g:GetCount()>0 then
					Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
				end
			end
		end
	end
end
function cm.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function cm.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsAbleToDeck() then
		Duel.SendtoDeck(c,nil,1,REASON_EFFECT)
		c:ReverseInDeck()
	end
end
function cm.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFaceup() and not Duel.IsExistingMatchingCard(Card.IsType,c:GetControler(),LOCATION_GRAVE,0,1,nil,TYPE_MONSTER)
end
function cm.desfilter(c)
	return c:IsFacedown() and c:IsAbleToDeck()
end
function cm.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
end
function cm.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,cm.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		Duel.Destroy(g,REASON_EFFECT,LOCATION_DECKSHF)
	end
end