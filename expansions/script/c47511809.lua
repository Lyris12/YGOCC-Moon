--Base delle Operazioni Deltaingranaggi
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--activate
	c:Activate()
	--stats
	c:UpdateATKDEFField(500,500,nil,LOCATION_MZONE,0,aux.TargetBoolFunction(Card.IsSetCard,0xfa6))
	--onsummon
	c:SummonedFieldTrigger(nil,false,true,true,true,0,nil,true,nil,true,aux.EventGroupCond(s.cfilter),nil,s.target,s.operation)
end

function s.cfilter(c,_,tp)
	return c:IsFaceup() and c:IsSetCard(0xfa6) and c:GetSummonPlayer()==tp
end
function s.filter(c,e,tp)
	return c:IsSetCard(0xfa6) and (not e and c:IsAbleToHand() or (e and Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,tp)
	local b2=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 end
	local opt=aux.Option(id,tp,1,b1,b2)
	if opt==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	elseif opt==1 then
		e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
	e:SetLabel(opt)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	local opt=e:GetLabel()
	if opt==0 then
		local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif opt==1 then
		local g=Duel.Select(HINTMSG_TOHAND,false,tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.Search(g,tp)
		end
	end
end