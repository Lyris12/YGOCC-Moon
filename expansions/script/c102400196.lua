--created & coded by Lyris, art from Yu-Gi-Oh! Duel Monsters GX Episode 101
--フェイツ儀式
local cid,id=GetID()
function cid.initial_effect(c)
	aux.AddRitualProcGreater2(c,aux.FilterBoolFunction(Card.IsSetCard,0xf7a),LOCATION_HAND+LOCATION_SZONE)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetCondition(aux.exccon)
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(cid.tg)
	e1:SetOperation(cid.op)
	c:RegisterEffect(e1)
end
function cid.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xf7a)
end
function cid.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function cid.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_GRAVE,0,1,3,nil)
	if #g>0 then
		Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
	end
end
