--Grenade Type - Explosion

local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_DESTROY|CATEGORY_ATKCHANGE|CATEGORY_DAMAGE)
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
	local g=c:GlitchyGetColumnGroup(1,1,true):Filter(aux.Faceup(Card.IsLocation),nil,LOCATION_MZONE)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,0,LOCATION_MZONE,-2000)
	local ct=g:FilterCount(Card.IsAttackBelow,nil,2000)
	if ct>0 then
		g:AddCard(c)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*500)
	else
		Duel.SetCardOperationInfo(c,CATEGORY_DESTROY)
		Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.Destroy(c,REASON_EFFECT)>0 and c:IsPreviousLocation(LOCATION_MZONE) then
		local g=c:GlitchyGetPreviousColumnGroup(1,1,true):Filter(aux.Faceup(Card.IsLocation),nil,LOCATION_MZONE)
		if #g==0 then return end
		local dg=Group.CreateGroup()
		for tc in aux.Next(g) do
			local preatk=tc:GetAttack()
			local e1,diff=tc:UpdateATK(-2000,true,c)
			if diff~=0 and tc:IsAttack(0) and not tc:IsImmuneToEffect(e1) then
				dg:AddCard(tc)
			end
		end
		Duel.AdjustAll()
		if #dg==0 then return end
		local ct=Duel.Destroy(dg,REASON_EFFECT)
		if ct>0 then
			Duel.BreakEffect()
			Duel.Damage(1-tp,500*ct,REASON_EFFECT)
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