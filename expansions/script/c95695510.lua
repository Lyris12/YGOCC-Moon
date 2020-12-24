--Lotus Blade Arte - Jigen
--Commissioned by: Leon Duvall
--Scripted by: Remnance & Lyris
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(cid.condition)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.operation)
	c:RegisterEffect(e1)
	--act in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e2:SetCondition(cid.handcon)
	c:RegisterEffect(e2)
	--search
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+17)
	e3:SetTarget(cid.thtg)
	e3:SetOperation(cid.thop)
	c:RegisterEffect(e3)
end
--filters
function cid.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3ff)
end
function cid.costfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x3ff)
		and Duel.IsExistingMatchingCard(cid.clfilter,tp,0,LOCATION_ONFIELD,1,nil,c,tp)
end
function cid.clfilter(c,tc,tp)
	local g=tc:GetColumnGroup()
	return g:IsContains(c) and c:IsFaceup()
end
function cid.thfilter(c)
	return c:IsSetCard(0x3ff) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
--activate
function cid.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_ONFIELD,0,2,nil)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_ONFIELD) and cid.costfilter(chkc,tp) and chkc~=e:GetHandler() end
	if chk==0 then return Duel.IsExistingTarget(cid.costfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,cid.costfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler(),tp)
	local cl=g:GetFirst():GetColumnGroup():Filter(aux.AND(Card.IsFaceup,Card.IsControler),nil,1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,cl,#cl,0,0)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local cl=tc:GetColumnGroup():Filter(aux.AND(Card.IsFaceup,Card.IsControler),nil,1-tp)
		Duel.Destroy(cl,REASON_EFFECT)
	end
end
--act in hand
function cid.handcon(e)
	return Duel.IsExistingMatchingCard(cid.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
--search
function cid.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cid.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cid.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end