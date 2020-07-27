--created & coded by Lyris, art from Cardfight!! Vanguard's "Dynamite Juggler"
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(TIMINGS_CHECK_MONSTER)
	e1:SetDescription(1124)
	e1:SetCondition(function(e) return e:GetHandler():IsSetCard(0x2c74) end)
	e1:SetTarget(cid.sptg)
	e1:SetOperation(cid.spop)
	c:RegisterEffect(e1)
end
function cid.filter(c,e,tp)
	return c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:GetOverlayGroup():IsExists(cid.filter,1,nil,e,tp)
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_OVERLAY)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil),1,0,0)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	if Duel.SpecialSummon(c:GetOverlayGroup():FilterSelect(tp,cid.filter,1,1,nil,e,tp),0,tp,tp,false,false,POS_FACEUP)>0 and tc:IsRelateToEffect(e) then
		Duel.BreakEffect()
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
