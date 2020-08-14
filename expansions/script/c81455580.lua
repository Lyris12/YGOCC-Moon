--created by Meedogh, coded by Meedogh & Lyris
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(cid.tg)
	e1:SetOperation(cid.op)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetTarget(cid.schtg)
	e3:SetOperation(cid.schop)
	c:RegisterEffect(e3)
end
function cid.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xcf11)
end
function cid.schfilter(c,n)
	return c:IsSetCard(0xcf11) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function cid.schfilter1(c)
	return c:IsCode(52460549) and c:IsAbleToHand()
end
function cid.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function cid.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local sel=0
		if Duel.IsExistingMatchingCard(cid.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then sel=sel+1 end
		if Duel.IsExistingMatchingCard(cid.schfilter,tp,LOCATION_DECK,0,1,nil) then sel=sel+2 end
		e:SetLabel(sel)
		return sel~=0
	end
	local sel=e:GetLabel()
	if sel==3 then
		Duel.Hint(HINT_SELECTMSG,tp,556)
		sel=Duel.SelectOption(tp,1100,1109)+1
	elseif sel==1 then
		Duel.SelectOption(tp,1100)
	else
		Duel.SelectOption(tp,1109)
	end
	e:SetLabel(sel)
	if sel==1 then
		local g=Duel.GetMatchingGroup(cid.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		e:SetCategory(CATEGORY_DESTROY)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	else
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
function cid.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sel=e:GetLabel()
	if sel==1 then
		local g=Duel.GetMatchingGroup(cid.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local dg=g:Select(tp,1,1,nil)
			Duel.HintSelection(dg)
			Duel.Destroy(dg,REASON_EFFECT)
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,cid.schfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
function cid.schtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.schfilter1,tp,LOCATION_DECK,0,1,nil,0) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cid.schop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cid.schfilter1,tp,LOCATION_DECK,0,1,1,nil,0)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
