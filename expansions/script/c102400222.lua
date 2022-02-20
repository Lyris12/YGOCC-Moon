--YC.Org Research Database
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(cid.sptg)
	e2:SetOperation(cid.spop)
	c:RegisterEffect(e2)
	--excavate
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id+100)
	e3:SetCondition(cid.exccon)
	e3:SetCost(cid.exccost)
	e3:SetTarget(cid.exctg)
	e3:SetOperation(cid.excop)
	c:RegisterEffect(e3)
	local e3x=e3:Clone()
	e3x:SetDescription(aux.Stringid(id,2))
	e3x:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3x)
	--spsummon
	local e3y=Effect.CreateEffect(c)
	e3y:SetDescription(aux.Stringid(id,3))
	e3y:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3y:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3y:SetCode(EVENT_DESTROYED)
	e3y:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3y:SetRange(LOCATION_SZONE)
	e3y:SetLabel(100)
	e3y:SetCountLimit(1,id+100)
	e3y:SetCondition(cid.exccon2)
	e3y:SetCost(cid.exccost)
	e3y:SetTarget(cid.exctg)
	e3y:SetOperation(cid.excop)
	c:RegisterEffect(e3y)
	local e3z=e3y:Clone()
	e3z:SetDescription(aux.Stringid(id,4))
	e3z:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3z)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,cid.counterfilter)
end
function cid.counterfilter(c)
	return c:IsSetCard(0x96B)
end
--SPECIAL SUMMON
function cid.filter(c)
	return c:IsSetCard(0x96B) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
function cid.spfilter(c,e,tp)
	return c:IsSetCard(0x96B) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and cid.filter(chkc) end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(cid.filter,tp,LOCATION_GRAVE,0,1,nil)
			and Duel.IsExistingMatchingCard(cid.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,cid.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,cid.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

--EXCAVATE
function cid.exccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function cid.cfilter2(c,tp)
	return c:IsSetCard(0x96B) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
function cid.exccon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cid.cfilter2,1,nil,tp)
end
function cid.exccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(cid.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function cid.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not cid.counterfilter(c)
end
function cid.exctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return false end
		local g=Duel.GetDecktopGroup(tp,3)
		local result=g:FilterCount(Card.IsAbleToHand,nil)>0
		return result
	end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
function cid.thfilter(c)
	return c:IsSetCard(0x96B) and c:IsAbleToHand()
end
function cid.excop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==100 and not e:GetHandler():IsRelateToEffect(e) then return end
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.ConfirmDecktop(p,3)
	local g=Duel.GetDecktopGroup(p,3)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_ATOHAND)
		local sg=g:FilterSelect(p,cid.thfilter,1,1,nil)
		if #sg>0 then
			if sg:GetFirst():IsAbleToHand() then
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-p,sg)
				Duel.ShuffleHand(p)
			else
				Duel.SendtoGrave(sg,REASON_RULE)
			end
		end
		Duel.ShuffleDeck(p)
	end
end