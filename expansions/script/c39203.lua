--Junkdust Synchron
--Automate ID

local scard,s_id=GetID()

function scard.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(s_id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,s_id)
	e1:SetCost(scard.spcost)
	e1:SetTarget(scard.sptg)
	e1:SetOperation(scard.spop)
	c:RegisterEffect(e1)
end
function scard.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function scard.spfilter(c,e,tp)
	return c:IsMonster() and ((c:IsSetCard(0xa3) and c:IsType(TYPE_SYNCHRO)) or (c:IsSetCard(0x43) and c~=e:GetHandler())) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function scard.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and scard.spfilter(chkc,e,tp) end
	if chk==0 then
		local exc = (e:GetLabel()==1) and e:GetHandler() or nil
		e:SetLabel(0)
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(scard.spfilter,tp,LOCATION_GRAVE,0,1,exc,e,tp)
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,scard.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_SPECIAL_SUMMON)
end
function scard.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and scard.spfilter(tc,e,tp) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
