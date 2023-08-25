--created by Swag, coded by XGlitchy30
--Leylah, Light of the Dreamy Forest
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigDoubleSidedType(c)
	aux.AddDoubleSidedProc(c,SIDE_OBVERSE,id+1,id)
	negate its effects, and if you do, you can make the ATK of 1 monster your opponent controls become 0, until the end of this turn.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_DISABLE|CATEGORY_ATKCHANGE)
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
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TRANSFORMED)
	e2:HOPT()
	e2:SetCondition(aux.PreTransformationCheckSuccessSingle)
	e2:SetCost(aux.TributeForSummonSelfCost(s.spfilter,LOCATION_HAND|LOCATION_DECK))
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	aux.AddPreTransformationCheck(c,e2,id+1)
	aux.AddDreamyDrearyTransformation(c,ARCHE_DREARY_FOREST)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and (Duel.IsMainPhase() or Duel.IsBattlePhase())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and aux.NegateAnyFilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_DISABLE)
end
function s.filter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and aux.NegateAnyFilter(tc) then
		local e1,e2,res=Duel.Negate(tc,e)
		if res then
			local g=Duel.Group(s.filter,tp,0,LOCATION_MZONE,nil)
			if #g>0 and tc:AskPlayer(tp,STRING_ASK_ATKCHANGE) then
				Duel.HintMessage(tp,HINTMSG_ATTACK)
				local sg=g:Select(tp,1,1,nil)
				if #sg>0 then
					Duel.HintSelection(sg)
					sg:GetFirst():ChangeATK(0,RESET_PHASE|PHASE_END,e:GetHandler())
				end
			end
		end
	end
end
function s.spfilter(c)
	return c:IsCode(id+2)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local check = e:GetLabel()==1 or (Duel.GetMZoneCount(tp)>0 and Duel.IsExistingMatchingCard(aux.SSFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp))
		e:SetLabel(0)
		return check
	end
	e:SetLabel(0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.SSFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
