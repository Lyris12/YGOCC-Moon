--Paradox Dragon of the Six Dimensions
--Drago Paradosso delle Sei Dimensioni
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.AddOrigTimeleapType(c)
	aux.AddTimeleapProc(c,7,s.TLcon,{s.TLfilter,true})
	c:EnableReviveLimit()
	--Check materials
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetLabel(0,0)
	e0:SetValue(s.valcheck)
	c:RegisterEffect(e0)
	--If this card is Time Leap Summoned: You can activate the appropriate effect, depending on the card type of the monster used as material;
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetLabelObject(e0)
	e1:SetFunctions(aux.TimeleapSummonedCond,nil,s.target,s.operation)
	c:RegisterEffect(e1)
end
function s.TLcon(e,c,tp)
	return Duel.GetMatchingGroupCount(Card.IsMonster,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK|TYPE_BIGBANG|TYPE_TIMELEAP)>=6
end
function s.TLfilter(c,e,mg)
	local tc=e:GetHandler()
	return c:IsMonster(TYPE_EFFECT)
		and (c:IsLevel(tc:GetFuture()-1) or (c:IsSummonLocation(LOCATION_EXTRA) and c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsStatus(STATUS_SPSUMMON_TURN) and tc:IsFuture(7)))
end

--E0
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local tc=g:GetFirst()
	local tpe,tpecustom=0,0
	if tc then
		local typ=tc:GetType()
		tpe=typ&(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK|TYPE_BIGBANG)
		if typ&TYPE_BIGBANG>0 then
			tpecustom=1
		end
		if typ&TYPE_TIMELEAP>0 then
			tpecustom=tpecustom|2
		end
	end
	e:SetLabel(tpe,tpecustom)
end

--E1
function s.fusfilter(c,e,tp)
	return c:IsMonster() and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.xyzfilter1(c,tp)
	return c:IsCanOverlay() and not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsExists(false,s.xyzfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
function s.xyzfilter2(c)
	return c:IsFaceup() and c:IsMonster(TYPE_XYZ)
end
function s.bbfilter(c)
	return c:IsFaceup() and not c:IsNeutral()
end
function s.check(tpe,tpecustom,e,tp,forcedtpe)
	if forcedtpe and ((tpe~=0 and forcedtpe&tpe==0) or (tpecustom~=0 and forcedtpe&tpecustom==0)) then return false end
	if tpe&TYPE_FUSION>0 then
		if Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,s.fusfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) then
			return true
		end
	end
	if tpe&TYPE_SYNCHRO>0 then
		if Duel.IsPlayerCanDraw(tp,1) then
			return true
		end
	end
	if tpe&TYPE_XYZ>0 then
		if Duel.IsExists(false,s.xyzfilter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,tp) then
			return true
		end
	end
	if tpe&TYPE_LINK>0 then
		local attg=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
		if attg:GetClassCount(Card.GetAttribute)>0 then
			return true
		end
	end
	if tpecustom&0x1>0 then
		if Duel.IsExists(false,s.bbfilter,tp,0,LOCATION_MZONE,1,nil) then
			return true
		end
	end
	if tpecustom&0x2>0 then
		if Duel.IsExists(false,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) then
			return true
		end
	end
	return false
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tpe,tpecustom=e:GetLabelObject():GetLabel()
	if chk==0 then
		return (tpe~=0 or tpecustom~=0) and s.check(tpe,tpecustom,e,tp)
	end
	local opt=aux.Option(tp,id,1,
		s.check(tpe,0,e,tp,TYPE_FUSION),
		s.check(tpe,0,e,tp,TYPE_SYNCHRO),
		s.check(tpe,0,e,tp,TYPE_XYZ),
		s.check(tpe,0,e,tp,TYPE_LINK),
		s.check(0,tpecustom,e,tp,0x1),
		s.check(0,tpecustom,e,tp,0x2)
	)
	if not opt then return end
	if opt==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
		
	elseif opt==1 then
		e:SetCategory(CATEGORY_DRAW)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
		Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	
	elseif opt==2 then
		e:SetCategory(CATEGORY_TOGRAVE)
		local g=Duel.Group(s.xyzfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,g,1,PLAYER_ALL,LOCATION_MZONE)
	
	elseif opt==3 then
		e:SetCategory(CATEGORIES_ATKDEF)
		local c=e:GetHandler()
		local attg=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
		local ct=attg:GetClassCount(Card.GetAttribute)
		Duel.SetCustomOperationInfo(0,CATEGORIES_ATKDEF,c,1,c:GetControler(),LOCATION_MZONE,ct*300)
		
	elseif opt==4 then
		e:SetCategory(CATEGORY_DESTROY)
		local g=Duel.Group(s.bbfilter,tp,0,LOCATION_MZONE,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,1-tp,LOCATION_MZONE)
	
	elseif opt==5 then
		e:SetCategory(CATEGORY_REMOVE)
		local g=Duel.Group(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,1-tp,LOCATION_ONFIELD)
	end
	e:SetLabel(opt)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local opt=e:GetLabel()
	if opt==0 then
		if Duel.GetMZoneCount(tp)<=0 then return end
		local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(s.fusfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummonNegate(e,g,0,tp,tp,false,false,POS_FACEUP)
		end
	
	elseif opt==1 then
		if Duel.Draw(tp,1,REASON_EFFECT)>0 then
			local tc=Duel.GetOperatedGroup():GetFirst()
			if aux.PLChk(tc,tp,LOCATION_HAND) then
				Duel.ConfirmCards(1-tp,tc)
				if tc:IsMonster(TYPE_TUNER) and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,STRING_ASK_DRAW) then
					Duel.BreakEffect()
					Duel.Draw(tp,1,REASON_EFFECT)
				end
			end
		end
	
	elseif opt==2 then
		local g1=Duel.Select(HINTMSG_ATTACH,false,tp,s.xyzfilter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,tp)
		if #g1>0 then
			Duel.HintSelection(g1)
			local g2=Duel.Select(HINTMSG_ATTACHTO,false,tp,s.xyzfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,g1)
			if #g2>0 then
				Duel.HintSelection(g2)
				local xyz=g2:GetFirst()
				if Duel.Attach(g1,xyz)>0 and xyz:IsAbleToGrave() and Duel.SelectYesNo(tp,STRING_ASK_SEND_TO_GY) then
					Duel.BreakEffect()
					Duel.SendtoGrave(xyz,REASON_EFFECT)
				end
			end
		end
	
	elseif opt==3 then
		local c=e:GetHandler()
		if not c:IsRelateToChain() or not c:IsFaceup() then return end
		local attg=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
		local ct=attg:GetClassCount(Card.GetAttribute)
		if ct>0 then
			c:UpdateATKDEF(ct*300,nil,true)
		end
	
	elseif opt==4 then
		local g=Duel.Group(s.bbfilter,tp,0,LOCATION_MZONE,nil)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	
	elseif opt==5 then
		local g=Duel.Select(HINTMSG_REMOVE,false,tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.Banish(g)
		end
	end	
end