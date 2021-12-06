--Sharicite
--coded by Concordia,cred Kretin and André
function c68709321.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68709321,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,68709321)
	e1:SetTarget(c68709321.target)
	e1:SetOperation(c68709321.activate)
	c:RegisterEffect(e1)
	--Recycle
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68709321,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(aux.exccon)
	e2:SetCost(c68709321.thcost)
	e2:SetTarget(c68709321.thtg)
	e2:SetOperation(c68709321.thop)
	c:RegisterEffect(e2)
end
function c68709321.filter(c,e,tp)
	return c:IsSetCard(0xf08) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c68709321.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c68709321.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c68709321.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c68709321.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c68709321.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c68709321.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function c68709321.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chck)
    if chck then return chck:IsControler(tp) and chck:IsLocation(LOCATION_GRAVE) end
    if chk==0 then return Duel.IsExistingTarget(c68709321.thfilter,tp,LOCATION_GRAVE,0,2,nil,e:GetHandler()) and Duel.IsPlayerCanDraw(tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,c68709321.thfilter,tp,LOCATION_GRAVE,0,2,2,nil,e:GetHandler())
end
function c68709321.thfilter(c)
	return c:IsSetCard(0xf08) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function c68709321.thop(e,tp,eg,ep,ev,re,r,rp)
	local 
	g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
	Duel.ShuffleDeck(tp)
	Duel.BreakEffect()		
	Duel.Draw(tp,1,REASON_EFFECT)
end
