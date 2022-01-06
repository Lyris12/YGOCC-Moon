--Automate ID
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97000273,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--send replace
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.repcon)
	e1:SetOperation(s.repop)
	c:RegisterEffect(e1)
end
function s.repcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5 and c:IsReason(REASON_DESTROY)
		and c:GetReasonPlayer()~=e:GetHandlerPlayer()
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.adjfil(c,seq,tp)
	if c:IsControler(tp) then
		return math.abs(seq-c:GetSequence())==1
			or (c:GetSequence()==5 and (seq==0 or seq==2))
			or (c:GetSequence()==6 and (seq==2 or seq==4))
	else
		return math.abs((4-seq)-c:GetSequence())==1
			or (c:GetSequence()==5 and (seq==2 or seq==4))
			or (c:GetSequence()==6 and (seq==0 or seq==2))
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local seq=c:GetSequence()
		if Duel.Destroy(c,REASON_EFFECT)>0 then
			local dg=Group.CreateGroup()
			local g=Duel.GetMatchingGroup(s.adjfil,tp,LOCATION_MZONE,LOCATION_MZONE,nil,seq,tp)
			for tc in aux.Next(g) do
				local e6=Effect.CreateEffect(c)
				e6:SetType(EFFECT_TYPE_SINGLE)
				e6:SetCode(EFFECT_CANNOT_ATTACK)
				e6:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e6)
			end
		end
	end
end
