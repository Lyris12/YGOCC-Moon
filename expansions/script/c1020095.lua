--C.VIATRIX: Portale
--Script by XGlitchy30
function c1020095.initial_effect(c)
	--link procedure
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),3)
	--draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1020095,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c1020095.lkcon)
	e1:SetCost(c1020095.lkcost)
	e1:SetTarget(c1020095.lktg)
	e1:SetOperation(c1020095.lkop)
	c:RegisterEffect(e1)
	--atk boost
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1020095,2))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,1020095)
	e2:SetCondition(c1020095.atkcon)
	e2:SetOperation(c1020095.atkop)
	c:RegisterEffect(e2)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1020095,3))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,1120095)
	e3:SetCondition(c1020095.spcon)
	e3:SetTarget(c1020095.sptg)
	e3:SetOperation(c1020095.spop)
	c:RegisterEffect(e3)
end
--filters
function c1020095.costfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x39c) and c:IsType(TYPE_MONSTER)
		and c:IsReleasable() and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function c1020095.draws(c)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE)
end
function c1020095.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:GetLevel()<=4 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--draw
function c1020095.lkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c1020095.lkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	--draw check
	local dts=Duel.GetMatchingGroupCount(c1020095.draws,tp,LOCATION_MZONE,0,e:GetHandler())
	local cg=Duel.GetMatchingGroup(c1020095.costfilter,tp,LOCATION_MZONE,0,e:GetHandler())
	if chk==0 then return Duel.CheckReleaseGroup(tp,c1020095.costfilter,1,e:GetHandler()) and dts>1 end
	local ct
	if dts>3 then ct=dts else ct=dts-1 end
	local g=Duel.SelectReleaseGroup(tp,c1020095.costfilter,1,ct,e:GetHandler())
	if #g>0 then
		Duel.Release(g,REASON_COST)
	end
end
function c1020095.lktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local dts=Duel.GetMatchingGroup(c1020095.draws,tp,LOCATION_MZONE,0,e:GetHandler())
	if chk==0 then return #dts>0 and Duel.IsPlayerCanDraw(tp,#dts) end
	e:SetLabel(dts:GetCount())
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,dts:GetCount())
end
function c1020095.lkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,e:GetLabel(),REASON_EFFECT)
end
--atk boost
function c1020095.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=a:GetBattleTarget()
	return a:IsControler(tp) and a:IsRace(RACE_CYBERSE) and a~=e:GetHandler() and d
		and not d:IsControler(tp)
end
function c1020095.atkop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	if a:IsRelateToBattle() and a:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(1000)
		a:RegisterEffect(e1)
	end
end
--spsummon
function c1020095.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousControler()==tp
end
function c1020095.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c1020095.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) 
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function c1020095.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c1020095.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end