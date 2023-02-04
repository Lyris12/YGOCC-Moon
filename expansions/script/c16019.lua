--Paracyclis Emperor, Ultimate Paralyze

local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFun2(c,s.matfilter(TYPE_LINK),s.matfilter(TYPE_FUSION),true)
	aux.AddContactFusionProcedureGlitchy(c,0,false,SUMMON_TYPE_FUSION,Card.IsAbleToExtraAsCost,LOCATION_MZONE,0,nil,s.matop)
	--change pos
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(aux.FusionSummonedCond)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
	--apply battle effects
	local e2=Effect.CreateEffect(c)
	e2:Desc(2)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(aux.TributeCost())
	e2:SetOperation(s.retop)
	e2:SetCountLimit(1,id)
	c:RegisterEffect(e2)
end
function s.matfilter(typ)
	return	function(c)
				return c:IsFusionSetCard(0x308) and c:IsFusionType(typ)
			end
end
function s.matop(g,e,tp,eg,ep,ev,re,r,rp,c)
	local cg=g:Filter(Card.IsFacedown,nil)
	if cg:GetCount()>0 then
		Duel.ConfirmCards(1-c:GetControler(),cg)
	end
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST|REASON_FUSION|REASON_MATERIAL)
end

function s.tsfilter(c,tp)
	return not c:IsCanTurnSetGlitchy(tp) and c:IsFaceup()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g1=Duel.GetMatchingGroup(Card.IsCanTurnSetGlitchy,tp,0,LOCATION_MZONE,nil,tp)
	local g2=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,g1,tp)
	if #g1>0 then
		Duel.SetOperationInfo(0,CATEGORY_POSITION,g1,#g1,1-tp,LOCATION_MZONE)
	end
	if #g2>0 then
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g2,#g2,1-tp,LOCATION_MZONE)
	end
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g0=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	local g1=Duel.GetMatchingGroup(Card.IsCanTurnSetGlitchy,tp,0,LOCATION_MZONE,nil,tp)
	if #g1>0 then
		for tc in aux.Next(g0) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EVENT_CHANGE_POS)
			e1:SetLabelObject(e)
			e1:SetCondition(s.regcon)
			e1:SetOperation(s.register_poschange)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN)
			tc:RegisterEffect(e1)
		end
		Duel.ChangePosition(g1,POS_FACEDOWN_DEFENSE)
		local og=Duel.GetMatchingGroup(Card.HasFlagEffect,tp,0,LOCATION_MZONE,nil,id)
		local g2=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,og)
		if #g2>0 then
			Duel.SendtoGrave(g2,REASON_EFFECT)
		end
	end
	local tg=Duel.GetMatchingGroup(Card.IsPosition,tp,0,LOCATION_MZONE,nil,POS_FACEDOWN_DEFENSE)
	for tc in aux.Next(tg) do
		local e1=Effect.CreateEffect(c)
		e1:Desc(3)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCondition(s.limcon)
		if Duel.GetTurnPlayer()==tp then
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
		else
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
		end
		e1:SetLabel(Duel.GetTurnCount(),tp)
		tc:RegisterEffect(e1)
	end
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsPreviousPosition(POS_FACEDOWN_DEFENSE) and c:IsPosition(POS_FACEDOWN_DEFENSE) and re and re==e:GetLabelObject()
end
function s.register_poschange(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE,1)
end
function s.limcon(e)
	local ct,tp=e:GetLabel()
	return Duel.GetTurnCount()>ct and Duel.GetTurnPlayer()==1-tp
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--halve damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x308))
	e1:SetValue(HALF_DAMAGE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--pierce
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x308))
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
	--hints
	Duel.RegisterHint(tp,id,PHASE_END,1,id,4)
	Duel.RegisterHint(1-tp,id,PHASE_END,1,id,5)
	Duel.RegisterHint(tp,id+100,PHASE_END,1,id,6)
end