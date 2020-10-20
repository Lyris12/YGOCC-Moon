--created by LionHeartKIng, coded by Lyris, art at http://nicolelbates.com/wp-content/uploads/2012/07/Lightning-Bolt-by-Todd-Secki.jpg
--襲雷ラッシュ
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.operation)
	c:RegisterEffect(e1)
end
function cid.filter(c)
	return c:IsSetCard(0x7c4) and c:IsType(TYPE_PENDULUM) and c:IsFaceup()
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(cid.filter,tp,LOCATION_EXTRA,0,nil)
	local pg=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		and g:GetClassCount(Card.GetCode)>=3-pg:FilterCount(Card.IsSetCard,nil,0x7c4) end
	g:Merge(pg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,3,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_PZONE,0,nil,0x7c4)
	local mg=Duel.GetMatchingGroup(cid.filter,tp,LOCATION_EXTRA,0,nil)
	for tc in aux.Next(g) do mg:Remove(Card.IsCode,nil,tc:GetCode()) end
	local ct=3-g:GetClassCount(Card.GetCode)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tg=mg:SelectSubGroup(tp,aux.dncheck,false,ct,ct)
	Duel.Destroy(tg+Duel.GetFieldGroup(tp,LOCATION_PZONE,0),REASON_EFFECT)
	local dt=Duel.GetOperatedGroup():FilterCount(function(c,dg) return dg:IsContains(c) end,nil,g+tg)
	if dt>=3 then
		Duel.BreakEffect()
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
