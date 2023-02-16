--Intellettualucertola
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--SS + Search
	local e1=c:Ignition(0,CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND,nil,LOCATION_GRAVE,{1,0,EFFECT_COUNT_CODE_DUEL},nil,
						s.cost,aux.LabelCheck(s.lcheck,s.check,aux.SelfInfo(CATEGORY_SPECIAL_SUMMON)),s.operation)
	e1:SetLabel(0)
end

function s.cf(c,_,tp)
	return c:IsMonster() and c:IsFaceup() and c:IsRace(RACE_REPTILE+RACE_DINOSAUR) and Duel.GetMZoneCount(tp,c)>0
end
function s.thf(c,rc,lv)
	return c:IsMonster() and c:IsRace(RACE_REPTILE+RACE_DINOSAUR-rc) and lv and c:HasOriginalLevel() and c:GetOriginalLevel()<lv and c:IsAbleToHand()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if e:GetLabelObject() then e:SetLabelObject(nil) end
	if chk==0 then return aux.ToGraveCost(s.cf,LOCATION_MZONE,0,1,1)(e,tp,eg,ep,ev,re,r,rp,0) end
	local g=aux.ToGraveCost(s.cf,LOCATION_MZONE,0,1,1)(e,tp,eg,ep,ev,re,r,rp,1)
	if #g>0 then
		e:SetLabelObject(g:GetFirst())
	end
end
function s.lcheck(e,tp)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function s.check(e,tp)
	return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local clab=e:GetLabel()
	local ec=e:GetLabelObject()
	if c and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and e:IsActivated() and ec then
		local rc,lv=ec:GetOriginalRace(),ec:GetOriginalLevel()
		if not ec:HasOriginalLevel() then lv=false end
		if Duel.IsExistingMatchingCard(s.thf,tp,LOCATION_DECK,0,1,nil,rc,lv) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,s.thf,tp,LOCATION_DECK,0,1,1,nil,rc,lv)
			if #g>0 then
				Duel.Search(g,tp)
			end
		end
	end
end