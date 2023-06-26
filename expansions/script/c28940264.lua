--Lights in the Marionightte
local ref,id=GetID()
Duel.LoadScript("Marionightte.lua")
function ref.initial_effect(c)
	Marionightte.Induct(c,0)
	--Bigbang
	c:EnableReviveLimit()
	aux.AddOrigBigbangType(c)
	aux.AddBigbangProc(c,ref.matfilter,1)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(ref.acttg)
	e1:SetOperation(ref.actop)
	c:RegisterEffect(e1)
	--Summon Restrict
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_BIGBANG) end)
	c:RegisterEffect(e2)
	--Base Bigbang Stats
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_BASE_BIGBANG_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(function(e,c,bc,mg) return mg and #mg>1 end)
	e3:SetValue(function(e,c,bc,mg) return 1200,true end)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_BASE_BIGBANG_DEFENSE)
	c:RegisterEffect(e4)
end
function ref.matfilter(c,g) return (not g) or g:IsExists(Marionightte.Is,1,nil) end

--Activate
function ref.actfilter(c,tp)
	return c:IsCode(Marionightte.ID) and c:GetActivateEffect():IsActivatable(tp)
		and not Duel.IsExistingMatchingCard(ref.notfilter,tp,LOCATION_ONFIELD,0,1,nil,c:GetOriginalCode())
end
function ref.notfilter(c,code)
	return c:IsFaceup() and c:GetOriginalCode()==code
end
function ref.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE>0)
		and Duel.IsExistingMatchingCard(ref.actfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp)
	end
end
function ref.actop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,ref.actfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp)
	if #g>0 then
		local tc=g:GetFirst()
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		local te=tc:GetActivateEffect()
		local tep=tc:GetControler()
		local cost=te:GetCost()
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
	end
end

--Summon Restrict
function ref.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_BIGBANG)
end
