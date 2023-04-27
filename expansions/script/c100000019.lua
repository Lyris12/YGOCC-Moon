--Zerost Moby
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddZerostMonsterEffects(c,CATEGORIES_SEARCH|CATEGORY_TOGRAVE,nil,s.target,s.operation)
end
s.toss_dice = true

function s.cfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_ZEROST) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		if tc and tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,STRING_ADD_TO_HAND,STRING_SEND_TO_GY)==0) then
			Duel.Search(tc,tp)
		else
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end
