--created by Pina, coded by Lyris
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(Card.IsSummonLocation,tp,0,LOCATION_MZONE,1,nil,LOCATION_EXTRA) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.SelectTarget(tp,Card.IsSummonLocation,tp,0,LOCATION_MZONE,1,1,nil,LOCATION_EXTRA),1,0,0)
end
function s.desfilter1(c,mc)
	return mc:GetLinkedGroup():IsContains(c)
end
function s.desfilter2(g)
	local sg=Group.CreateGroup()
	for tc in aux.Next(g) do
		local fid=tc:GetFieldID()
		local lg=tc:GetLinkedGroup()
		for sc in aux.Next(lg) do
			sc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1,fid)
			sg:AddCard(sc)
		end
	end
	return sg
end
function s.desfilter3(c,g,t)
	local res=false
	for tc in aux.Next(g) do
		if c:GetFlagEffectLabel(id)==t[tc] or c:GetFlagEffectLabel(id)==tc:GetFieldID() then res=true end
	end
	return res
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local fid={[tc]=tc:GetFieldID()}
	local g=Duel.GetMatchingGroup(s.desfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tc)
	if not tc:IsRelateToEffect(e) or Duel.Destroy(tc,REASON_EFFECT)==0 or not tc:IsType(TYPE_LINK) then return end
	for sc in aux.Next(g) do fid[sc]=sc:GetFieldID() end
	local lg=s.desfilter2(g)
	local dt=200
	Duel.BreakEffect()
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup()
		dt=dt+#og*200
		local sg=lg:Filter(s.desfilter3,nil,og,fid)
		while #sg>0 do
			Duel.BreakEffect()
			for sc in aux.Next(sg) do fid[sc]=sc:GetFieldID() end
			lg=s.desfilter2(sg)
			if Duel.Destroy(sg,REASON_EFFECT)==0 then break end
			og=Duel.GetOperatedGroup()
			dt=dt+#og*200
			sg=lg:Filter(s.desfilter3,nil,og,fid)
		end
		Duel.BreakEffect()
		Duel.Damage(tp,dt,REASON_EFFECT,true)
		Duel.Damage(1-tp,dt,REASON_EFFECT,true)
		Duel.RDComplete()
	end
end
