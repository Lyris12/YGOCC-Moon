--SKILL: Operazione Chirurgica
--Script by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	aux.AddOrigSkillType(c)
	--ED Skill Properties
	aux.EDSkillProperties(c)
	--Storm Access
	local SKILL=Effect.CreateEffect(c)
	SKILL:SetType(EFFECT_TYPE_FIELD)
	SKILL:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	SKILL:SetRange(LOCATION_EXTRA)
	SKILL:SetCode(EFFECT_SPSUMMON_PROC_G)
	SKILL:SetCondition(cid.skillcon_skill)
	SKILL:SetOperation(cid.skillop)
	SKILL:SetValue(SUMMON_TYPE_SPECIAL+1)
	c:RegisterEffect(SKILL)
end
--filters
function cid.filter(c,g,code,lv,tp,e)
	if not code and not lv then
		return c:IsType(TYPE_MONSTER) and c:IsLevelBelow(2) and g:IsExists(cid.filter,1,c,g,c:GetCode(),c:GetLevel(),tp,e)
	else
		return c:IsType(TYPE_MONSTER) and c:IsCode(code) and c:GetLevel()==lv and Duel.IsExistingMatchingCard(cid.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetLevel(),nil,0)
	end
end
function cid.spfilter(c,e,tp,lv,code,stop)
	return c:IsType(TYPE_MONSTER) and c:GetLevel()==lv and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (not code or c:IsCode(code))
		and (stop==1 or Duel.IsExistingMatchingCard(cid.spfilter,tp,LOCATION_DECK,0,1,c,e,tp,lv,c:GetCode(),1))
end
--Storm Access
function cid.skillcon_skill(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetFieldGroup(tp,LOCATION_GRAVE,0)
	return aux.skillcon(e) and Duel.GetFlagEffect(tp,id)<=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and g:IsExists(cid.filter,1,nil,g,nil,nil,tp,e)
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
end
function cid.skillop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_CARD,1-tp,id)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	local rg=Duel.GetFieldGroup(tp,LOCATION_GRAVE,0):Filter(cid.filter,nil,rg,nil,nil,tp,e)
	if #rg<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rc=rg:Select(tp,1,1,nil)
	local lv,code=rc:GetFirst():GetLevel(),rc:GetFirst():GetCode()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rc2=rg:FilterSelect(tp,cid.spfilter,1,1,rc:GetFirst(),rg,code,lv,tp,e)
	rc:Merge(rc2)
	if #rc>0 and Duel.Remove(rc,POS_FACEUP,REASON_RULE)~=0 then
		local sg=Duel.GetMatchingGroup(cid.spfilter,tp,LOCATION_DECK,0,nil,e,tp,lv,nil,0)
		if #sg<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=sg:Select(tp,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc2=sg:FilterSelect(tp,cid.spfilter,1,1,sc:GetFirst(),e,tp,lv,sc:GetFirst():GetCode(),1)
		sc:Merge(sc2)
		if #sc>0 then
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	Duel.RegisterFlagEffect(tp,id,0,0,1)
	return
end