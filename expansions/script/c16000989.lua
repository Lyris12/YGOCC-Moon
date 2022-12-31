--Conjoint Sorceress
function c16000989.initial_effect(c)
	aux.AddOrigEvoluteType(c)
	c:EnableReviveLimit()
	aux.AddEvoluteProc(c,nil,5,c16000989.filter1,1)  
	--Conjoint Procedure
	aux.AddOrigConjointType(c)
	aux.EnableConjointAttribute(c,5)
	--When this card is Evolute Summoned:You can Conjoint 1 monster from your hand to this card. (HOpT)
	--If this card is Conjointed with another card: You can remove 4 E-C from this card; Special Summon 2 monsters from your Deck with the Same name of the Conjoint momster to this card, also negate their effects, and cannot be used as Materials for a Summon, except Evolute Materials for a Summon. (HOpT)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16000989,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,16000989)
	e1:SetCondition(c16000989.drcon)
	e1:SetTarget(c16000989.drtg)
	e1:SetOperation(c16000989.drop)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16000989,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,16000990)
	e2:SetCondition(c16000989.condition)
	e2:SetCost(c16000989.cost)
	e2:SetTarget(c16000989.target)
	e2:SetOperation(c16000989.activate)
	c:RegisterEffect(e2)
end
function c16000989.filter1(c,ec,tp)
	return not c:IsType(TYPE_TOKEN)
end
function c16000989.mtfilter(c,e)
	return c:IsType(TYPE_MONSTER) 
end
function c16000989.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+388
end
function c16000989.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsType(TYPE_XYZ)
		and Duel.IsExistingMatchingCard(c16000989.mtfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,e) end
end
function c16000989.drop(e,tp,eg,ep,ev,re,r,rp)
	 local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,c16000989.mtfilter,tp,LOCATION_HAND,0,1,1,nil,e)
	if g:GetCount()>0 then
		Duel.Overlay(c,g)
		
	end
end

function c16000989.condition(e,tp,eg,ep,ev,re,r,rp)
   return  e:GetHandler():GetOverlayCount()~=0
end
function c16000989.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	   if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,2,REASON_COST) end
	e:GetHandler():RemoveEC(tp,2,REASON_COST)
end
function c16000989.filter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_EVOLUTE) and not c:IsCode(16000989)
		and Duel.IsExistingMatchingCard(c16000989.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetAttribute())
end
function c16000989.spfilter(c,e,tp,att)
	return c:IsAttribute(att) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c16000989.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c16000989.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c16000989.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,c16000989.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c16000989.activate(e,tp,eg,ep,ev,re,r,rp)
   local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or not c:RemoveOverlayCard(tp,1,1,REASON_EFFECT) or not tc:RemoveEC(tp,2,REASON_EFFECT) or tc:IsFacedown() then return end
   local g=Duel.GetMatchingGroup(c16000989.spfilter,tp,LOCATION_DECK,0,tc:GetAttribute()) 
	local sg=Duel.SelectMatchingCard(tp,(c16000989.spfilter),tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetAttribute())
	if sg:GetCount()>0 and Duel.SpecialSummonStep(sg:GetFirst(),0,tp,tp,false,false,POS_FACEUP_DEFENSE)  then
		local e69=Effect.CreateEffect(e:GetHandler())
		e69:SetType(EFFECT_TYPE_SINGLE)
		e69:SetCode(EFFECT_DISABLE)
		e69:SetReset(RESET_EVENT+RESETS_STANDARD)
		sg:GetFirst():RegisterEffect(e69,true)
		local e0=Effect.CreateEffect(e:GetHandler())
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetCode(EFFECT_DISABLE_EFFECT)
		e0:SetReset(RESET_EVENT+RESETS_STANDARD)
		sg:GetFirst():RegisterEffect(e0,true)
	 local e1=Effect.CreateEffect(e:GetHandler())
 e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
				e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
				e1:SetValue(1)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				sg:GetFirst():RegisterEffect(e1,true)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
				sg:GetFirst():RegisterEffect(e2,true)
				 local e3=e1:Clone()
				e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
				tsg:GetFirst():RegisterEffect(e3,true)
				 local e4=e1:Clone()
				e4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
				sg:GetFirst():RegisterEffect(e4,true)
				 local e5=e1:Clone()
				e5:SetCode(EFFECT_CANNOT_BE_POLARITY_MATERIAL)
				sg:GetFirst():RegisterEffect(e5,true)
				 local e6=e1:Clone()
				e6:SetCode(EFFECT_CANNOT_BE_SPACE_MATERIAL)
				sg:GetFirst():RegisterEffect(e6,true)
					local e7=e1:Clone()
				e6:SetCode(EFFECT_CANNOT_BE_BIGBANG_MATERIAL)
				sg:GetFirst():RegisterEffect(e7,true)
		Duel.SpecialSummonComplete()
			   Duel.SpecialSummonComplete()
	end
end