--Portale Ciondolo
--Scripted by: XGlitchy30
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
	aux.AddOrigPandemoniumType(c)
	aux.EnablePandemoniumAttribute(c)
	--scale
	local p0=Effect.CreateEffect(c)
	p0:SetType(EFFECT_TYPE_SINGLE)
	p0:SetCode(EFFECT_CHANGE_RSCALE)
	p0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	p0:SetRange(LOCATION_SZONE)
	p0:SetCondition(cid.sccon)
	p0:SetValue(5)
	c:RegisterEffect(p0)
	--extra pande location
	local p1=Effect.CreateEffect(c)
	p1:SetType(EFFECT_TYPE_SINGLE)
	p1:SetCode(EFFECT_EXTRA_PANDEMONIUM_SUMMON_LOCATION)
	p1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	p1:SetRange(LOCATION_SZONE)
	p1:SetCondition(cid.extracon)
	p1:SetValue(cid.extraval)
	c:RegisterEffect(p1)
	--MONSTER EFFECTS
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCost(cid.spcost)
	e1:SetTarget(cid.sptg)
	e1:SetOperation(cid.spop)
	c:RegisterEffect(e1)
	local e1x=e1:Clone()
	e1x:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1x)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,cid.counterfilter)
end
--GENERIC FILTERS
function cid.counterfilter(c)
	return c:GetSummonLocation()~=LOCATION_EXTRA
end
--SCALE
function cid.sccon(e)
	return aux.PandActCheck(e) and Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)>0
end
function cid.excfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_PENDULUM+TYPE_PANDEMONIUM)
end
--EXTRA PANDE LOCATION
function cid.doubtfilter(c)
	return c:IsFacedown() or c:IsType(TYPE_MONSTER)
end
-------------
function cid.extracon(e)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetFieldGroup(tp,LOCATION_EXTRA+LOCATION_GRAVE,0)
	return aux.PandActCheck(e) and not Duel.IsExistingMatchingCard(cid.doubtfilter,tp,LOCATION_MZONE,0,1,nil)
		and #g>0 and not g:IsExists(cid.excfilter,1,nil)
end
function cid.extraval(mode,c,e,tp,lscale,rscale,eset,tg)
	if not mode then return false end
	if mode==0 then
		return LOCATION_DECK
	elseif mode==1 then
		return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_PANDEMONIUM)
	else
		return {[LOCATION_DECK]=1}
	end
end
--SPSUMMON
function cid.spfilter(c,e,tp)
	return c:IsFaceup() and ((c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) 
		or (c:GetFlagEffect(726)>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetCode(),0,aux.GetOriginalPandemoniumType(c)|TYPE_PANDEMONIUM,c:GetTextAttack(),c:GetTextDefense(),c:GetOriginalLevel(),c:GetOriginalRace(),c:GetOriginalAttribute())))
end
-------------
function cid.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)<=1 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetCondition(function (e,tp) return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)>=1 end)
	e1:SetTarget(cid.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function cid.splimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA)
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	local gct=Duel.GetMatchingGroupCount(cid.spfilter,tp,LOCATION_SZONE+LOCATION_PZONE,0,nil,e,tp)
	if ct>gct then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,gct,tp,LOCATION_SZONE+LOCATION_PZONE)
	else
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,LOCATION_SZONE+LOCATION_PZONE)
	end
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ct<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	local g=Duel.GetMatchingGroup(cid.spfilter,tp,LOCATION_SZONE+LOCATION_PZONE,0,nil,e,tp)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:Select(tp,ct,ct,nil)
	local tc=sg:GetFirst()
	while tc do
		if tc:IsType(TYPE_PENDULUM) then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			tc:AddMonsterAttribute(aux.GetOriginalPandemoniumType(tc)|TYPE_PANDEMONIUM)
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
		tc=sg:GetNext()
	end
end