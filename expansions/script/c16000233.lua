--Paintress Gorgia 
function c16000233.initial_effect(c)
		aux.EnablePendulumAttribute(c)
		--salvage
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetDescription(aux.Stringid(16000233,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	--e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,16000233)
	e1:SetCost(c16000233.thcost)
	e1:SetTarget(c16000233.thtg)
	e1:SetOperation(c16000233.thop)
	c:RegisterEffect(e1)

	--Negate
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(16000233,1))
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOEXTRA)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCountLimit(1,16001233)
	--e4:SetCost(c16000233.cost)
	e4:SetTarget(c16000233.target)
	e4:SetOperation(c16000233.operation)
	c:RegisterEffect(e4)
end
function c16000233.rmfilter(c,e,tp)
	return c:IsFaceup() and  c:IsSetCard(0xc50)  and c:IsAbleToRemoveAsCost()
		and Duel.IsExistingTarget(c16000233.filterx,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,c,e,tp)
end
function c16000233.filterx(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_EFFECT) and c:IsAbleToHand()
end
function c16000233.thcost(e,tp,eg,ep,ev,re,r,rp,chk)	
if chk==0 then return Duel.IsExistingMatchingCard(c16000233.rmfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
local g=Duel.SelectMatchingCard(tp,c16000233.rmfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c16000233.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingMatchingCard(c16000233.filterx,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
function c16000233.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c16000233.filterx,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
  if Duel.GetFlagEffect(tp,16000233)~=0 then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(16000233,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetTarget(c16000233.disable)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	Duel.RegisterFlagEffect(tp,16000233,RESET_PHASE+PHASE_END,0,1)

	end
end
function c16000233.disable(e,c)
	return not c:IsType(TYPE_EFFECT) or not bit.band(c:GetOriginalType(),TYPE_EFFECT)==TYPE_EFFECT
end
function c16000233.filter(c,e,tp,b1,setcode)
	return c:IsType(TYPE_PENDULUM) and c:IsType(TYPE_NORMAL) and not c:IsForbidden()
		and (b1 or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function c16000233.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(16000233)~=0
end
function c16000233.sumfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsSummonable(true,nil)
end
function c16000233.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c16000233.sumfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function c16000233.sumop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,c16000233.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.Summon(tp,tc,true,nil)
	end
end
function c16000233.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable()  end
 Duel.Release(e:GetHandler(),REASON_COST)
end
function c16000233.filter(c,e,tp,b1,setcode)
	return c:IsType(TYPE_PENDULUM) and c:IsType(TYPE_NORMAL) and not c:IsForbidden()
		and (b1 or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function c16000233.filter2(c,e,tp,b2,setcode)
	return c:IsSetCard(0xc50) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
		and (b2 or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function c16000233.target(e,tp,eg,ep,ev,re,r,rp,chk)
	   local b1=Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then return (b1 or b2)
		and Duel.IsExistingMatchingCard(c16000233.filter,tp,LOCATION_DECK,0,1,nil,e,tp,b1,nil)
		and Duel.IsExistingMatchingCard(c16000233.filter2,tp,LOCATION_DECK,0,1,nil,e,tp,b1,nil) end
	 Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
end
function c16000233.operation(e,tp,eg,ep,ev,re,r,rp)
	 local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	local b1=Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if not b1 and not b2 then return end
	local g1=Duel.GetMatchingGroup(c16000233.filter,tp,LOCATION_DECK,0,nil,e,tp,b1,nil)
	local g2=Duel.GetMatchingGroup(c16000233.filter2,tp,LOCATION_DECK,0,nil,e,tp,b1,nil)
	if g1:GetCount()==0 or g2:GetCount()==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local sg1=g1:Select(tp,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local sg2=g2:Select(tp,1,1,nil)
	sg1:Merge(sg2)
	Duel.ConfirmCards(1-tp,sg1)
	Duel.ShuffleDeck(tp)
	local cg=sg1:Select(1-tp,1,1,nil)
	local tc=cg:GetFirst()
	Duel.Hint(HINT_CARD,0,tc:GetCode())
	if b1 and (not b2 or not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or Duel.SelectYesNo(tp,aux.Stringid(16000233,0))) then
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	else
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	sg1:RemoveCard(tc)
	Duel.SendtoExtraP(sg1,nil,REASON_EFFECT)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c16000233.sumlimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
end
function c16000233.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not ( c:IsSetCard(0xc50) or not c:IsType(TYPE_EFFECT))
end