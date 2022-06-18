--Marmotandem
--Scripted by: XGlitchy30
local s,id=GetID()

function s.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_BEAST),2,2,s.lcheck)
	c:EnableReviveLimit()
	--disable field
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE+LOCATION_SZONE)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCustomCategory(CATEGORY_PLACE_AS_CONTINUOUS_TRAP,CATEGORY_FLAG_SELF)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.condition)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	aux.GlobalCheck(s,s.func(e1,c))
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
function s.func(ex,c)
	return function()
			local ge1=Effect.CreateEffect(c)
			ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			ge1:SetCode(EVENT_ADJUST)
			ge1:SetLabelObject(ex)
			ge1:SetOperation(s.checkop)
			Duel.RegisterEffect(ge1,0)
	end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsOnField() or not e:GetHandler():IsFaceup() then return end
	local e1=e:GetLabelObject()
	e1:Reset()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE+LOCATION_SZONE)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetOperation(s.disop)
	e:GetHandler():RegisterEffect(e1)
	e:SetLabelObject(e1)
end
--LINK SUMMON
function s.lcheck(g,lc,sumtype,tp)
	return g:GetClassCount(Card.GetLinkAttribute)==g:GetCount()
end
--DISABLE FIELD
function s.disop(e,tp)
	local c=e:GetHandler()
	local zone=aux.GLGetLinkedZoneManually(c,true)
	return 0x1f001f&zone
end

--SPSUMMON
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:GetRace()&(~(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINGEDBEAST))>0
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil)
end
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsRace(RACE_BEAST)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_BEAST) and c:IsLocation(LOCATION_EXTRA)
end
function s.spfilter(c,e,tp,ct)
	if not c:IsRace(RACE_BEAST) or c:GLGetLevel()>ct or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	return (not c:IsLocation(LOCATION_EXTRA) and Duel.GetMZoneCount(tp,e:GetHandler())>0) or Duel.GetLocationCountFromEx(tp,tp,e:GetHandler(),c)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=0
		local incr=(tp==0) and 1 or -1
		for p=tp,1-tp,incr do
			for i=0,4 do
				local index=(p==tp) and i or 4-i
				if not Duel.CheckLocation(p,LOCATION_MZONE,i) and not Duel.GetFieldGroup(p,LOCATION_MZONE,0):IsExists(s.zcheck,1,nil,i,p) then
					ct=ct+1
				end
			end
		end
		return ct>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and not e:GetHandler():IsForbidden() and Duel.GetMZoneCount(tp,e:GetHandler())>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp,ct)
	end
	Duel.SetCustomOperationInfo(0,CATEGORY_PLACE_AS_CONTINUOUS_TRAP,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_MZONE)
end
function s.zcheck(c,i,tp)
	local zone=0x1<<i
	return aux.IsZone(c,zone,tp)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain(0) or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if not c:IsImmuneToEffect(e) and Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		local ct=0
		local incr=(tp==0) and 1 or -1
		for p=tp,1-tp,incr do
			for i=0,4 do
				local index=(p==tp) and i or 4-i
				if not Duel.CheckLocation(p,LOCATION_MZONE,i) and not Duel.GetFieldGroup(p,LOCATION_MZONE,0):IsExists(s.zcheck,1,nil,i,p) then
					ct=ct+1
				end
			end
		end
		if ct>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp,ct) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp,ct):GetFirst()
			if tc then
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end