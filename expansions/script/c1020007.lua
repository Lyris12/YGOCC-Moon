--[[
CODED-EYES Machina Dragon
Card Author: Jake
Original script by: ?
Fixed by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	if not s.progressive_id then
		s.progressive_id=id+1
	else
		s.progressive_id=s.progressive_id+1
	end
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:HOPT()
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DAMAGE_STEP)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:HOPT()
	e2:SetCondition(aux.dscon)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	--raise atk
	aux.RegisterMergedDelayedEventGlitchy(c,s.progressive_id,EVENT_TO_GRAVE,s.evfilter,id,LOCATION_MZONE,nil,LOCATION_MZONE)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_CUSTOM+s.progressive_id)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
--E1
function s.atkcheck(c)
	return not c:IsAttack(c:GetBaseAttack())
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsRace,RACE_MACHINE),tp,LOCATION_MZONE,0,nil)
	return #g>=2 and g:IsExists(s.atkcheck,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	Duel.SpecialSummonRedirect(e,c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end

--E2
function s.filter(c,tp)
	return c:IsFaceup() and c:IsSetCard(ARCHE_CODE_JAKE) and Duel.IsExists(false,aux.FaceupFilter(Card.IsLevelAbove,1),tp,LOCATION_MZONE,0,1,c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	local atk=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsLevelAbove,1),tp,LOCATION_MZONE,0,tc):GetSum(Card.GetLevel)*100
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,tc,1,0,0,atk)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		local atk=math.floor(Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsLevelAbove,1),tp,LOCATION_MZONE,0,tc):GetSum(Card.GetLevel)/2)*100
		if atk>0 then
			local c=e:GetHandler()
			tc:UpdateATK(atk,true,{c,true})
		end
	end
end

--E3
function s.evfilter(c,_,tp)
	return c:IsMonster() and c:IsSetCard(ARCHE_CODE_JAKE) and c:IsControler(tp)
end
function s.tgcheck(c,tp)
	return c:IsMonster() and c:IsControler(tp)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(s.tgcheck,nil,tp)
	if chkc then return g:IsContains(chkc) end
	if chk==0 then
		return g:IsExists(Card.IsCanBeEffectTarget,1,nil,e)
	end
	if #g>1 then
		g=g:FilterSelect(tp,Card.IsCanBeEffectTarget,1,1,nil,e)
	end
	Duel.SetTargetCard(g)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,0,0,{g:GetFirst():GetAttack()})
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsMonster() and tc:IsLocation(LOCATION_GRAVE) and c:IsRelateToChain() and c:IsFaceup() then
		c:ChangeATK(tc:GetAttack(),RESET_PHASE|PHASE_END,c)
	end
end