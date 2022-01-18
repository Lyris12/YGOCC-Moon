--Amuleto di Giada Spektrale
--Scripted by: XGlitchy30
local s,id = GetID()

function s.initial_effect(c)
	--cannot link material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCountLimit(1,id)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(s.sharedcost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		local g1=Effect.CreateEffect(c)
		g1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		g1:SetCode(EVENT_SUMMON_SUCCESS)
		g1:SetOperation(s.regop)
		Duel.RegisterEffect(g1,0)
		local g2=g1:Clone()
		g2:SetCode(EVENT_SPSUMMON_SUCCESS)
		Duel.RegisterEffect(g2,0)
		local g3=g1:Clone()
		g3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
		Duel.RegisterEffect(g3,0)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	for p=0,1 do
		if eg:IsExists(s.counterfilter,1,c,p) then
			Duel.RegisterFlagEffect(p,id,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
function s.counterfilter(c,p)
	return not c:IsAttribute(ATTRIBUTE_DARK) and c:GetSummonPlayer()==p
end
function s.sharedcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)<=0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.sumlimit)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	Duel.RegisterEffect(e3,tp)
	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_OATH)
	e4:SetDescription(aux.Stringid(id,4))
	e4:SetReset(RESET_PHASE+PHASE_END)
	e4:SetTargetRange(1,0)
	Duel.RegisterEffect(e4,tp)
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_DARK)
end

function s.spfilter(c)
	return c:IsSetCard(0x27a) and c:IsDiscardable() and not c:IsCode(id)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,c)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,c)
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,901019,0x27a,TYPES_TOKEN_MONSTER+TYPE_TUNER,0,0,2,RACE_INSECT,ATTRIBUTE_DARK)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		if Duel.GetLocationCount(tp,LOCATION_MZONE,tp)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,901019,0x27a,TYPES_TOKEN_MONSTER+TYPE_TUNER,0,0,2,RACE_INSECT,ATTRIBUTE_DARK) then
			local token=Duel.CreateToken(tp,901019)
			if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetDescription(aux.Stringid(901019,0))
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CLIENT_HINT)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(1)
				token:RegisterEffect(e1,true)
			end
		end
	end
	Duel.SpecialSummonComplete()
end