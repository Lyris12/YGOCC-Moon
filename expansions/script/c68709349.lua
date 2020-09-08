--HDD's Struggle
local cid,id=GetID()
function cid.initial_effect(c)
	--You can only activate 1 "HDD's Struggle" per turn.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	--You can target 1 "HDD" monster you control, and up to 2 cards your opponent controls;  destroy the first target, and if you do, destroy the other targets.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetTarget(cid.target)
	e2:SetOperation(cid.operation)
	c:RegisterEffect(e2)
end
function cid.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf09)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if chk==0 then return Duel.IsExistingTarget(cid.cfilter,tp,LOCATION_MZONE,0,1,nil)
		and #g>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectTarget(tp,cid.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,2,nil)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,#g1,0,0)
end
function cid.filter(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsControler(tp)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local sc=e:GetLabelObject()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)-sc
	if sc:IsFacedown() or not sc:IsSetCard(0xf09) or sc:IsControler(1-tp) or Duel.Destroy(sc,REASON_EFFECT)==0 then return end
	g:RemoveCard(sc)
	Duel.Destroy(g:Filter(cid.filter,nil,e,1-tp),REASON_EFFECT)
end
