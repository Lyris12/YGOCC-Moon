--革新者的新血 库洛依
function c33700324.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33700324,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_DESTROY)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c33700324.sptg)
	e1:SetOperation(c33700324.spop)
	c:RegisterEffect(e1)	  
end
function c33700324.spfilter(c,e,tp)
	return c:IsSetCard(0x1449) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetMZoneCount(tp,e:GetHandler())>0
end
function c33700324.thfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsAbleToHand() and c:IsSetCard(0x1449)
end
function c33700324.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDestructable() and (Duel.IsExistingMatchingCard(c33700324.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) or Duel.IsExistingMatchingCard(c33700324.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function c33700324.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(c33700324.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
	local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(c33700324.thfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	local op
	if #g1>0 and #g2>0 then
		op=Duel.SelectOption(tp,aux.Stringid(33700323,1),aux.Stringid(33700323,2))
	elseif #g1>0 then
		op=Duel.SelectOption(tp,aux.Stringid(33700323,1))
	else
		op=Duel.SelectOption(tp,aux.Stringid(33700323,2))+1
	end
	if op==nil then return end
	local g=(op==0) and g1 or g2
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if not tc then return end
	if tc:IsLocation(LOCATION_REMOVED) then
	   Duel.SendtoHand(tc,nil,REASON_EFFECT)
	   Duel.ConfirmCards(1-tp,tc)
	elseif tc:IsLocation(LOCATION_GRAVE) then
	   if op==1 then
		  Duel.SendtoHand(tc,nil,REASON_EFFECT)
		  Duel.ConfirmCards(1-tp,tc)
	   else
		  Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	   end
	else
	   Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end