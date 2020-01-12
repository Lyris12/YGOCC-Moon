--graze
xpcall(function() require("expansions/script/c37564765") end,function() require("script/c37564765") end)
local m,cm=Senya.SayuriSpellPreload(37564902)
function cm.initial_effect(c)
	Senya.SayuriSelfReturnCommonEffect(c,m)
	aux.AddCodeList(c,37564904)
	aux.AddCodeList(c,37564905)
	aux.AddCodeList(c,37564906)
	aux.AddCodeList(c,37564907)
	aux.AddCodeList(c,37564908)
	aux.AddCodeList(c,37564909)
	aux.AddCodeList(c,37564910)
	aux.AddCodeList(c,37564911)
	aux.AddCodeList(c,37564912)
	aux.AddCodeList(c,37564913)
	aux.AddCodeList(c,37564915)
	aux.AddCodeList(c,37564916)
	aux.AddCodeList(c,37564921)
	aux.AddCodeList(c,37564552)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
	Senya.sayuri_activate_effect[c]=e1
end
function cm.filter(c,e,tp,mg,ft)
	if not Senya.check_set_sayuri(c) or (c:GetType() & 0x81)~=0x81
		or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	local mg=mg:Filter(Card.IsCanBeRitualMaterial,c,c)
	if c:IsCode(21105106) then return c:ritual_custom_condition(mg,ft) end
	if c.mat_filter then
		mg=mg:Filter(c.mat_filter,nil)
	end
	return Senya.CheckRitualMaterial(c,mg,tp,c:GetLevel())
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetRitualMaterial(tp)
		local ft=Duel.GetMZoneCount(tp)
		return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,mg,ft)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetRitualMaterial(tp)
	local ft=Duel.GetMZoneCount(tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cm.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,mg,ft)
	local tc=tg:GetFirst()
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc:IsCode(21105106) then
			tc:ritual_custom_operation(mg)
			local mat=tc:GetMaterial()
			Senya.SayuriCheckTrigger(tc,e,tp,eg,ep,ev,re,r,rp)
			Duel.ReleaseRitualMaterial(mat)
		else
			if tc.mat_filter then
				mg=mg:Filter(tc.mat_filter,nil)
			end
			local mat=Senya.SelectRitualMaterial(tc,mg,tp,tc:GetLevel())
			tc:SetMaterial(mat)
			Senya.SayuriCheckTrigger(tc,e,tp,eg,ep,ev,re,r,rp)
			Duel.ReleaseRitualMaterial(mat)
		end
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end