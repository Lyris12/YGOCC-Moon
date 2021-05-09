Auxiliary={}
aux=Auxiliary

--Pastel Palettes filter for level 6 or 7 monster
function Auxiliary.LvL6or7Check(c)
	return c:IsLevel(6,7) and c:IsSetCard(0x880)
end
--Pastel Palettes common special summon from grave by return itself to the hand
--parameters
--c: card
--id: hopt
function Auxiliary.AddPastelPalettesSpSummonEffect(c,id,desc)
	local eff=Effect.CreateEffect(c)
	eff:SetDescription(desc)
	eff:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	eff:SetType(EFFECT_TYPE_QUICK_O)
	eff:SetHintTiming(0,TIMING_END_PHASE)
	eff:SetCode(EVENT_FREE_CHAIN)
	eff:SetCountLimit(1,id)
	eff:SetRange(LOCATION_MZONE)
	eff:SetTarget(Auxiliary.PastelPalettesSpSummonTarget)
	eff:SetOperation(Auxiliary.PastelPalettesSpSummonOperation)
	return eff
end
function Auxiliary.PastelPalettesSpSummonFilter(c,e,tp)
	return aux.LvL6or7Check(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function Auxiliary.PastelPalettesSpSummonTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand()
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(Auxiliary.PastelPalettesSpSummonFilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function Auxiliary.PastelPalettesSpSummonOperation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	if Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Auxiliary.PastelPalettesSpSummonFilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if sg:GetCount()>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
--Level 6 or 7 Pastel Palettes common return itself from the field to Deck
--parameters
--c: card
--desc: stringid from cdb
--id: hopt
--except: except itself and the other copy with it
function Auxiliary.EnablePastelPalettesReturn(c,desc1,desc2,id,except)
	local eff=Effect.CreateEffect(c)
	eff:SetDescription(desc1)
	eff:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	eff:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	eff:SetCode(EVENT_PHASE+PHASE_BATTLE)
	eff:SetRange(LOCATION_MZONE)
	eff:SetCountLimit(1,id)
	eff:SetTarget(Auxiliary.PastelPalettesReturnTarget(except))
	eff:SetOperation(Auxiliary.PastelPalettesReturnOperation(except,desc2))
	c:RegisterEffect(eff)
end
function Auxiliary.PastelPalettesSpSummonFilter2(c,e,tp) 
	return not aux.LvL6or7Check(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function Auxiliary.PastelPalettesToGraveFilter(c,except) 
	return not c:IsCode(except) and aux.LvL6or7Check(c) and c:IsAbleToGrave()
end
function Auxiliary.PastelPalettesReturnTarget(except)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then
					local c=e:GetHandler()
					return c:IsAbleToHand()
						and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
						and Duel.IsExistingMatchingCard(Auxiliary.PastelPalettesSpSummonFilter2,tp,LOCATION_HAND,0,1,nil,e,tp)
						and Duel.IsExistingMatchingCard(Auxiliary.PastelPalettesToGraveFilter,tp,LOCATION_DECK,0,1,nil,except) 
				end
				Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
				Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
				Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
			end
end
function Auxiliary.PastelPalettesReturnOperation(except,desc2)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local c=e:GetHandler()
				if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,2,REASON_EFFECT)~=0 then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,Auxiliary.PastelPalettesSpSummonFilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp)
					if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.SelectYesNo(tp,desc2) then
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
						local sg=Duel.SelectMatchingCard(tp,Auxiliary.PastelPalettesToGraveFilter,tp,LOCATION_DECK,0,1,1,nil,except)
						if sg:GetCount()>0 then
							Duel.SendtoGrave(sg,REASON_EFFECT)
						end
					end
				end
			end
end
