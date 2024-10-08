--Grenade Type - Flash

local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_DESTROY|CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--send replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(s.repcon)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	local c=e:GetHandler()
	Duel.SetCardOperationInfo(c,CATEGORY_DESTROY)
	local g=c:GlitchyGetColumnGroup(1,1,true):Filter(Card.IsLocation,nil,LOCATION_MZONE):Filter(aux.NegateMonsterFilter,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,LOCATION_MZONE)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.Destroy(c,REASON_EFFECT)>0 and c:IsPreviousLocation(LOCATION_MZONE) then
		local g=c:GlitchyGetPreviousColumnGroup(1,1,true):Filter(Card.IsLocation,nil,LOCATION_MZONE):Filter(aux.NegateMonsterFilter,nil):Filter(Card.IsCanBeDisabledByEffect,nil,e)
		if #g==0 then return end
		local phase=Duel.GetCurrentPhase()
		if phase>=PHASE_BATTLE_START and phase<=PHASE_DAMAGE_CAL then phase=PHASE_BATTLE end
		local reset=RESET_PHASE|phase
		for tc in aux.Next(g) do
			Duel.Negate(tc,e,reset)
		end
	end
end

function s.repcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5 and c:IsReason(REASON_DESTROY) and c:GetReasonPlayer()~=e:GetHandlerPlayer()
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT|(RESETS_STANDARD&(~RESET_TURN_SET)))
	e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
end