--Preserver of Ages
local id,cod=23251011,c23251011
function cod.initial_effect(c)
	--Link Summon
	aux.AddLinkProcedure(c,nil,2,2)
	c:EnableReviveLimit()
	--Salvage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(cod.retcost)
	e1:SetTarget(cod.rettg)
	e1:SetOperation(cod.retop)
	c:RegisterEffect(e1)
end
function cod.rfilter(c)
	return c:IsSetCard(0xd3e) and c:IsAbleToDeck()
end
function cod.retcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	if chk==0 then return lg:FilterCount(Card.IsReleasable,nil)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local sg=lg:FilterSelect(tp,Card.IsReleasable,1,1,nil)
	Duel.Release(sg,REASON_COST)
end
function cod.rettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(cod.rfilter,tp,LOCATION_GRAVE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,cod.rfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),tp,LOCATION_GRAVE)
end
function cod.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()<=0 then return end
	Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
end
