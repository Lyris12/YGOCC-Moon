--Flash Freeze
--Idea: Alastar Rainford
--Original Scripter: Shad3
--Rescripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TOGRAVE|CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.a_tg)
	e1:SetOperation(s.a_op)
	c:RegisterEffect(e1)
	--Search
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TOHAND|CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(aux.exccon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.b_tg)
	e2:SetOperation(s.b_op)
	c:RegisterEffect(e2)
end
function s.filter(c,tp)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.a_fil,tp,LOCATION_DECK,0,1,c,c)
end
function s.a_fil(c,cc)
	if not (c:IsSetCard(ARCHE_WINTER_SPIRIT) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()) then return false end
	local lv=c:GetLevel()
	return lv>0 and (not cc or cc:IsCanAddCounter(COUNTER_ICE,lv))
end
function s.a_tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,#g,COUNTER_ICE,1)
end
function s.a_op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local sc
	if not tc:IsRelateToChain() or not tc:IsFaceup() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		sc=Duel.SelectMatchingCard(tp,s.a_fil,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	else
		sc=Duel.ForcedSelect(HINTMSG_TOGRAVE,false,tp,s.a_fil,tp,LOCATION_DECK,0,1,1,tc):GetFirst()
	end
	local lv=sc:GetLevel()
	if Duel.SendtoGrave(sc,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_GRAVE) and tc:IsRelateToChain() and tc:IsFaceup() then
		tc:AddCounter(COUNTER_ICE,lv)
	end
end

function s.b_fil(c)
	return c:IsSetCard(ARCHE_WINTER_SPIRIT) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.b_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.b_fil,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.b_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.b_fil,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
