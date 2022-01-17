--Moneta d'Oro Spektrale
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
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCountLimit(1,id)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCost(s.sharedcost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--lvchange
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,id+100)
	e4:SetCost(s.sharedcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	--
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

function s.filter(c)
	return (c:IsSetCard(0x27a) and c:IsType(TYPE_SPELL+TYPE_TRAP) or c:IsSetCard(0x95) and c:IsType(TYPE_SPELL)) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,901019,0x27a,TYPES_TOKEN_MONSTER+TYPE_TUNER,0,0,2,RACE_INSECT,ATTRIBUTE_DARK)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	if ft<2 then return end
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,901019,0x27a,TYPES_TOKEN_MONSTER+TYPE_TUNER,0,0,2,RACE_INSECT,ATTRIBUTE_DARK) then return end
	local success=false
	for i=1,2 do
		local token=Duel.CreateToken(tp,901019)
		if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
			if not success then success=true end
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
	Duel.SpecialSummonComplete()
	if success then
		local xyz=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,0,nil)
		for tc in aux.Next(xyz) do
			local rk=tc:GetRank()
			--chk
			local e0=Effect.CreateEffect(e:GetHandler())
			e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e0:SetCode(EVENT_LEAVE_FIELD_P)
			e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE)
			e0:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e0:SetOperation(s.chk)
			tc:RegisterEffect(e0)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,5))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_UNCOPYABLE)
			e1:SetCode(EFFECT_GRANT_LEVEL)
			e1:SetLabel(rk)
			e1:SetRange(LOCATION_MZONE)
			e1:SetValue(s.lvval)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE)
			e3:SetCode(EFFECT_XYZ_LEVEL)
			e3:SetValue(s.constantlyupdate)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
			local e4=e3:Clone()
			e4:SetCode(EFFECT_ALLOW_SYNCHRO_KOISHI)
			e4:SetValue(0)
			tc:RegisterEffect(e4)
		end
	end
end
function s.chk(e,tp,eg,ep,ev,re,r,rp)
	local excreset=aux.GetExceptionReset(e:GetHandler():GetDestination())
	local e2=Effect.CreateEffect(e:GetOwner())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_REMEMBER_GRANTED_LEVEL)
	e2:SetRange(0xff)
	e2:SetValue(s.constantlyupdate)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD-excreset+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e2)
end
function s.constantlyupdate(e,c)
	return c:GetLevel()
end
function s.xyzfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsFaceup()
end
function s.lvval(e,c)
	return e:GetLabel()
end
function s.lvtargetp(e,c)
	return c:GetPreviousTypeOnField()&TYPE_XYZ>0
end
function s.lvvalp(e,c)
	return c:GetPreviousRankOnField()
end