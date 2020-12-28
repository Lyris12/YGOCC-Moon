--created by Meedogh, coded by Lyris
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(cid.condition)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
end
function cid.cfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
function cid.condition(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsChainNegatable(ev) or re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	if re:IsHasCategory(CATEGORY_NEGATE) and Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT):IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(cid.cfilter,nil,tp)-#tg>0
end
function cid.sfilter(c,e,tp)
	return c:IsCode(52401237) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_BIGBANG,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.sfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,1,nil,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
function cid.filter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.NegateActivation(ev) then return end
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	if ct>0 and Duel.Destroy(Duel.GetFieldGroup(tp,LOCATION_MZONE,0),REASON_EFFECT)==ct then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.sfilter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,nil,e,tp)
		local sc=sg:GetFirst()
		if sc then
			Duel.BreakEffect()
			if Duel.SpecialSummon(sc,SUMMON_TYPE_BIGBANG,tp,tp,false,false,POS_FACEUP)==0 then return end
			local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(cid.filter),tp,LOCATION_GRAVE,0,nil,tp)
			local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
			if #g>0 and ft>0 and Duel.SelectYesNo(tp,1068) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
				local qg=g:Select(tp,1,math.min(ft,ct),nil)
				for tc in aux.Next(qg) do
					if Duel.Equip(tp,tc,sc) then
						local e1=Effect.CreateEffect(e:GetHandler())
						e1:SetType(EFFECT_TYPE_SINGLE)
						e1:SetCode(EFFECT_EQUIP_LIMIT)
						e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
						e1:SetReset(RESET_EVENT+RESETS_STANDARD)
						e1:SetValue(cid.eqlimit)
						e1:SetLabelObject(gc)
						gc:RegisterEffect(e1)
					end
				end
			end
		end
	end
end
function cid.eqlimit(e,c)
	return c==e:GetLabelObject()
end
