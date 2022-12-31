--Evolute Cat
local ref=_G['c'..160009730]
function c160009730.initial_effect(c)
 
	--hand 
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_EXTRA_EVOLUTE_MATERIAL)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c160009730.matcon)
	--e1:SetValue(c160009730.matval)
	e1:SetOperation(ref.matop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCondition(c160009730.ctcon)
	e2:SetOperation(c160009730.ctop)
	c:RegisterEffect(e2)
	--search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(160009730,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,160009730)
	e3:SetCondition(c160009730.thcon)
	e3:SetTarget(c160009730.thtg)
	e3:SetOperation(c160009730.thop)
	c:RegisterEffect(e3)
end
function c160009730.matcon(c,ec,mode)
	if mode==1 then return Duel.GetFlagEffect(c:GetControler(),160009730)==0 and c:IsLocation(LOCATION_HAND) end
	return true
end
function c160009730.mfilter(c)
	return c:IsLocation(LOCATION_MZONE)
end
function c160009730.matval(e,c,mg)
	return  mg:IsExists(c160009730.mfilter,1,nil)
end
function ref.matop(c)
	Duel.SendtoGrave(c,REASON_MATERIAL+0x10000000)
end
function c160009730.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
function c160009730.ctop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,160009730,RESET_PHASE+PHASE_END,0,1)
end
function c160009730.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	e:SetLabel(0)
	if c:IsPreviousLocation(LOCATION_ONFIELD) then e:SetLabel(1) end
	return c:IsLocation(LOCATION_GRAVE) and c:IsPreviousLocation(LOCATION_ONFIELD+LOCATION_HAND) and r&(REASON_SUMMON+REASON_FUSION+REASON_SYNCHRO+REASON_RITUAL+REASON_XYZ+REASON_LINK)==0
end
function c160009730.thfilter(c,chk)
	return c:IsSetCard(0xc53) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function c160009730.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c160009730.thfilter,tp,LOCATION_DECK,0,1,nil,e:GetLabel()) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c160009730.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c160009730.thfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	if g:GetCount()>0 then
		Duel.SendtoHand(g,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end