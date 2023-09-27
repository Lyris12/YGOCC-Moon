--created by Swag, coded by XGlitchy30
--The Dreary Forest's Lightless Glade
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddDoubleSidedProc(c,SIDE_REVERSE,id-1)
	c:Activate()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCondition(aux.EndPhaseCond(1))
	e1:SetOperation(s.chainop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:Desc(0)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_FZONE)
	e2:HOPT()
	e2:SetCondition(s.effcon)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TRANSFORMED)
	e3:SetRange(LOCATION_FZONE)
	e3:HOPT()
	e3:SetCondition(aux.PreTransformationCheckSuccess)
	e3:SetTarget(aux.IsCanTransformTargetFunction)
	e3:SetOperation(aux.TransformOperationFunction(SIDE_OBVERSE))
	c:RegisterEffect(e3)
	aux.AddPreTransformationCheck(c,e3,s.tfcon)
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end
end
s.triggering_setcode_check={}
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	local eid=re:GetFieldID()
	if rc:IsControler(tp) and rc:IsSetCard(ARCHE_DREARY_FOREST) then
		s.triggering_setcode_check[eid]=true
	else
		if s.triggering_setcode_check[eid]~=nil then
			s.triggering_setcode_check[eid]=false
		end
	end
end
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp and re:GetHandler():IsSetCard(ARCHE_DREAMY_FOREST,ARCHE_DREARY_FOREST) and re:GetOwnerPlayer()==tp then
		Duel.SetChainLimit(s.chainlm)
	end
end
function s.chainlm(e,rp,tp)
	return tp==rp
end
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local check=s.triggering_setcode_check[re:GetFieldID()]
	if not check then return false end
	local rc=re:GetHandler()
	return r&REASON_EFFECT==REASON_EFFECT and check==true and re:IsActiveType(TYPE_MONSTER)
		and re:GetActivateLocation()==LOCATION_MZONE and eg:IsExists(Card.IsPreviousControler,1,nil,1-tp)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.efilter)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	Duel.RegisterEffect(e2,tp)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_REFLECT_DAMAGE)
	e3:SetTargetRange(1,0)
	e3:SetValue(s.refval)
	e3:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e3,tp)
	Duel.RegisterHint(tp,id,PHASE_END,1,id,2)
end
function s.efilter(e,c)
	return Duel.GetAttacker()==c and Duel.GetAttackTarget()==nil
end
function s.refval(e,re,ev,r,rp,rc)
	return r&REASON_EFFECT~=0
end
function s.tffilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(ARCHE_DREARY_FOREST)
end
function s.tfcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.tffilter,1,nil,tp)
end
