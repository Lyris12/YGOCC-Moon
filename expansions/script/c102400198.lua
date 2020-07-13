--created & coded by Lyris, art by flightless-angel
--フェイツ施し
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(cid.drawtg)
	e1:SetOperation(cid.drawop)
	c:RegisterEffect(e1)
end
function cid.discardfilter(c)
	return c:IsFacedown() and c:GetOriginalType()&TYPE_MONSTER~=0 and c:IsSetCard(0xf7a) and c:IsAbleToGrave()
end
function cid.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) and Duel.IsExistingMatchingCard(cid.discardfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function cid.drawop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,cid.discardfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	if Duel.SendtoGrave(g,REASON_EFFECT)==0 then return end
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.BreakEffect()
	Duel.Draw(p,d,REASON_EFFECT)
end
