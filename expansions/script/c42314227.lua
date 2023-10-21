--created by Jake, coded by XGlitchy30
--Survival at Dawn
if not global_override_reason_effect_check then
	global_override_reason_effect_check = true
end
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_ATTACK)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_CONFIRM)
	e2:SetRange(LOCATION_SZONE)
	e2:HOPT(true)
	e2:SetLabel(0)
	e2:SetCondition(s.atkcon)
	e2:SetCost(aux.LabelCost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.dawn_blader_monster_in_text = true
s.scapetoken = nil
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	local bc=Duel.GetAttackTarget()
	if not bc then return false end
	if tc:IsControler(1-tp) then bc,tc=tc,bc end
	return tc:IsFaceup() and tc:IsSetCard(0x613)
end
function s.cfilter(c)
	return c:IsMonster() and c:IsSetCard(0x613)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local exc = (e:IsHasType(EFFECT_TYPE_ACTIVATE) and c:IsLocation(LOCATION_HAND) and c:IsControler(tp)) and c or nil
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,exc)
	end
	e:SetLabel(0)
	local ct=Duel.DiscardHand(tp,Card.IsDiscardable,1,99,REASON_COST+REASON_DISCARD)
	if ct>0 then
		local og=Duel.GetOperatedGroup():Filter(s.cfilter,nil)
		if #og>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.HintMessage(tp,HINTMSG_OPERATECARD)
			local dg=og:Select(tp,1,#og,nil)
			if #dg>0 then
				Duel.HintSelection(dg)
				if not s.scapetoken then
					local token=Duel.CreateToken(tp,UNIVERSAL_GLITCHY_TOKEN)
					token:SetStatus(STATUS_NO_LEVEL,true)
					s.scapetoken=token
				end
				s.scapetoken:Recreate(id,0,0x613,(s.scapetoken:GetType()&~TYPE_NORMAL)|c:GetType(),0,0,0,0)
				local fake_re=e:Clone()
				s.scapetoken:RegisterEffect(fake_re,true)
				fake_re:SetCheatCode(GECC_OVERRIDE_ACTIVE_TYPE)
				e:SetCheatCode(GECC_OVERRIDE_REASON_EFFECT,true)
				e:SetCheatCodeValue(GECC_OVERRIDE_REASON_EFFECT,fake_re)
				for tc in aux.Next(dg) do
					Duel.RaiseSingleEvent(tc,EVENT_DISCARD,fake_re,REASON_COST+REASON_DISCARD,tp,tp,0)
				end
				Duel.RaiseEvent(dg,EVENT_DISCARD,fake_re,REASON_COST+REASON_DISCARD,tp,tp,0)
			end
		end
		Duel.SetTargetParam(ct)
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,1-tp,LOCATION_MZONE,-ct*300)
	else
		return
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	local ct=Duel.GetTargetParam()
	if not ct or ct<=0 then return end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if #g<=0 then return end
	local val=-ct*300
	for tc in aux.Next(g) do
		tc:UpdateATK(val,RESET_PHASE+PHASE_BATTLE,c)
	end
end
