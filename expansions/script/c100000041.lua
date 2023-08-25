--created by Swag, coded by XGlitchy30
--Leylah, Shine of the Dreamy Forest
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigDoubleSidedType(c)
	aux.AddDoubleSidedProc(c,SIDE_OBVERSE,id+1,id)
	You can target 1 monster your opponent controls; negate its effects, and if you do, it loses 1000 ATK.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_DISABLE|CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:HOPT()
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP|RELEVANT_TIMINGS)
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
	aux.AddDreamyDrearyTransformation(c,ARCHE_DREARY_FOREST)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and (Duel.IsMainPhase() or Duel.IsBattlePhase()) and aux.ExceptOnDamageCalc()
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,ARCHE_DREAMY_FOREST,ARCHE_DREARY_FOREST),tp,LOCATION_ONFIELD,0,1,e:GetHandler())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateMonsterFilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_DISABLE)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,g:GetFirst():GetControler(),g:GetFirst():GetLocation(),-1000)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and aux.NegateMonsterFilter(tc) then
		local e1,e2,res=Duel.Negate(tc,e)
		if res and tc:IsRelateToChain() and tc:IsFaceup() then
			tc:UpdateATK(-1000,true,e:GetHandler())
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
