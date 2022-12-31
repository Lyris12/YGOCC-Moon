--Pandemia della Rana
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DAMAGE+CATEGORY_DESTROY+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.tgfil(c)
	return c:IsMonster() and (c:IsSetCard(0x12) or c:IsCode(1357146)) and c:IsAbleToGrave()
end
function s.thfil(c)
	return c:IsMonster() and (c:IsSetCard(0x12) or c:IsCode(1357146)) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local exc = (chk==1 and e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsType(TYPE_CONTINUOUS+TYPE_EQUIP+TYPE_FIELD) and not e:GetHandler():IsHasEffect(EFFECT_REMAIN_FIELD)) and e:GetHandler() or nil
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,exc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfil,tp,LOCATION_DECK,0,1,nil) and #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,800)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfil,tp,LOCATION_DECK,0,1,3,nil)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE)
		local ct=og:GetCount()
		if ct==0 then return end
		if Duel.Damage(tp,ct*800,REASON_EFFECT)>0 then
			local exc = (e:GetHandler():IsRelateToChain(0) and e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsType(TYPE_CONTINUOUS+TYPE_EQUIP+TYPE_FIELD) and not e:GetHandler():IsHasEffect(EFFECT_REMAIN_FIELD)) and e:GetHandler() or nil
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,exc)
			if #dg>0 then
				Duel.BreakEffect()
				Duel.HintSelection(dg)
				Duel.Destroy(dg,REASON_EFFECT)
			end
		end
		local ct2=og:GetClassCount(Card.GetCode)
		if ct==3 and (ct2==1 or ct2==3) and Duel.IsExistingMatchingCard(s.thfil,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,s.thfil,tp,LOCATION_DECK,0,1,1,nil)
			if #g>0 then
				Duel.Search(g,tp)
			end
		end
	end
end