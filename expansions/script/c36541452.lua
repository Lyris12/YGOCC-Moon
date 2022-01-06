--Engraved Array - Diquis
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--synchro summon
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	--equip
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(cid.valcheck)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetLabelObject(e0)
	e1:SetCondition(cid.eqcon)
	e1:SetTarget(cid.eqtg)
	e1:SetOperation(cid.eqop)
	c:RegisterEffect(e1)
	--attribute
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_ADD_ATTRIBUTE)
	e2:SetCondition(cid.attgain)
	e2:SetValue(cid.attval)
	c:RegisterEffect(e2)
	--immunity
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(cid.efilter)
	c:RegisterEffect(e3)
	--spsummon (SYNCHRO)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_SET_AVAILABLE)
	e4:SetCode(EVENT_TO_DECK)
	e4:SetTarget(cid.sptg)
	e4:SetOperation(cid.spop)
	c:RegisterEffect(e4)
end
--EQUIP
function cid.valcheck(e,c)
	local g=c:GetMaterial()
	if e:GetLabelObject()~=nil then e:GetLabelObject():Clear() end
	local eg=(e:GetLabelObject()~=nil) and e:GetLabelObject() or Group.CreateGroup()
	for tc in aux.Next(g) do
		local eq=tc:GetEquipGroup()
		if #eq>0 then
			eg:Merge(eq)
		end
	end
	if #eg>0 then
		eg:KeepAlive()
		e:SetLabelObject(eg)
	end
end
--equip
function cid.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function cid.eqfilter(c,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function cid.eqfilter2(c,g)
	return c:IsType(TYPE_MONSTER) and c:CheckUniqueOnField(tp) and not c:IsForbidden() and (not g or not g:IsContains(c))
end
function cid.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local equip=e:GetLabelObject():GetLabelObject()
	local eq=(equip~=nil) and equip:Filter(cid.eqfilter,nil,tp) or nil
	local ct=(equip~=nil) and #eq or 0
	if chk==0 then return Duel.IsExistingMatchingCard(cid.eqfilter2,tp,LOCATION_GRAVE,0,1,nil,eq)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>(ct+1)
	end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,ct+1,PLAYER_ALL,LOCATION_GRAVE)
end
function cid.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local equip=e:GetLabelObject():GetLabelObject()
	if equip then
		local eq=equip:Filter(cid.eqfilter,nil,tp)
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if ft<(#eq+1) then return end
		if ft>=(#eq+1) then ft=#eq end
		for i=1,ft do
			local ec=eq:FilterSelect(tp,aux.NecroValleyFilter(nil),1,1,nil):GetFirst()
			eq:RemoveCard(ec)
			if Duel.Equip(tp,ec,c,true,true)~=0 then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetValue(cid.eqlimit)
				ec:RegisterEffect(e1)
			end
		end
	end
	local eq=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.eqfilter2),tp,LOCATION_GRAVE,0,1,1,nil,nil)
	local exeq=eq:GetFirst()
	if not Duel.Equip(tp,exeq,c,false) then return end
	--equip limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetValue(cid.eqlimit)
	exeq:RegisterEffect(e1)
	Duel.EquipComplete()
end
function cid.eqlimit(e,c)
	return e:GetOwner()==c
end

--ATTGAIN
function cid.attcheck(c,cc)
	return bit.band(c:GetOriginalType(),TYPE_MONSTER)>0 and c:GetOriginalAttribute()~=cc:GetAttribute()
end
function cid.attgain(e)
	local c=e:GetHandler()
	local eq=c:GetEquipGroup()
	return eq and eq:IsExists(cid.attcheck,1,nil,e:GetHandler())
end
function cid.attval(e,c)
	local attr=0
	local eq=c:GetEquipGroup()
	local tc=eq:GetFirst()
	while tc do
		local at=tc:GetOriginalAttribute()
		if at~=c:GetAttribute() then
			at=at&~(at&c:GetAttribute())
			attr=attr|(at&~(at&attr))
		end
		tc=eq:GetNext()
	end
	return attr
end

--IMMUNITY
function cid.efilter(e,te)
	return te:IsActiveType(TYPE_TRAP) and te:GetOwnerPlayer()~=e:GetHandlerPlayer() or (te:IsActiveType(TYPE_MONSTER) and te:GetHandler():IsLocation(LOCATION_MZONE) and te:GetHandlerPlayer()~=e:GetHandlerPlayer() and c:IsAttribute(e:GetHandler():GetAttribute()))
end

--SPSUMMON
function cid.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_EXTRA)
end
function cid.spfilter(c,e,tp,mc)
	return c:IsCode(id-1) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		and Duel.IsExistingMatchingCard(cid.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,cid.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil):GetFirst()
	if tc then
		Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end