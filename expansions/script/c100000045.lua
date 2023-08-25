--created by Swag, coded by XGlitchy30
--Leylah, Radiance of the Dreamy Forest
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigDoubleSidedType(c)
	aux.AddDoubleSidedProc(c,SIDE_OBVERSE,id+1,id)
	you can negate the effects of 1 face-up card your opponent controls, then you can make the ATK of 1 monster your opponent controls become 0.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_DESTROY|CATEGORY_DISABLE|CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:HOPT()
	e1:SetHintTiming(0,RELEVANT_TIMINGS)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TRANSFORMED)
	e2:HOPT()
	e2:SetCondition(aux.PreTransformationCheckSuccessSingle)
	e2:SetTarget(s.rettg)
	e2:SetOperation(s.retop)
	c:RegisterEffect(e2)
	aux.AddPreTransformationCheck(c,e2,id+1)
	aux.AddDreamyDrearyTransformation(c,ARCHE_DREARY_FOREST)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and (Duel.IsMainPhase() or Duel.IsBattlePhase())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_DESTROY)
end
function s.filter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and Duel.Destroy(tc,REASON_EFFECT)>0 then
		local c=e:GetHandler()
		local g1=Duel.Group(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
		if #g1>0 and c:AskPlayer(tp,STRING_ASK_DISABLE) then
			Duel.HintMessage(tp,HINTMSG_DISABLE)
			local sg1=g1:Select(tp,1,1,nil)
			if #sg1>0 then
				Duel.HintSelection(sg1)
				local e1,e2,res=Duel.Negate(sg1:GetFirst(),e)
				if res then
					local g2=Duel.Group(s.filter,tp,0,LOCATION_MZONE,nil)
					if #g2>0 and tc:AskPlayer(tp,STRING_ASK_ATKCHANGE) then
						Duel.HintMessage(tp,HINTMSG_ATTACK)
						local sg2=g2:Select(tp,1,1,nil)
						if #sg2>0 then
							Duel.HintSelection(sg2)
							sg2:GetFirst():ChangeATK(0,true,e:GetHandler())
						end
					end
				end
			end
		end
	end
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_ONFIELD)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
