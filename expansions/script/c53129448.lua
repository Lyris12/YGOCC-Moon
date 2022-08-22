--Singolarità Oscura
--Scripted by: XGlitchy30

s.effect_text = [[
● You can only use the ① effect of "Dark Singularity" once per turn.

① Target 1 face-up Xyz Monster on the field with no materials; attach as material to it, 1 monster in its same column or in an adjacent one, and if you do, attach 1 monster in the same column as the attached monster or in an adjacent one, and keep repeating this process until there are no more cards to attach, also, after that, if the targeted monster is the only monster on the field, destroy all other cards on the field.
]]

local s,id=GetID()
function s.initial_effect(c)
	c:Activate(0,{0,CATEGORY_ATTACH},EFFECT_FLAG_CARD_TARGET,false,{1,0},nil,nil,s.tg,s.op)
end

function s.xyzfilter(c)
	return c:IsFaceup() and c:IsMonster(TYPE_XYZ) and c:GetOverlayCount()==0 and c:GlitchyGetColumnGroup(1,1):IsExists(s.atcfilter,1,c)
end
function s.atcfilter(c,e)
	return c:IsLocation(LOCATION_MZONE) and c:MonsterOrFacedown() and c:IsCanOverlay() and (not e or not c:IsImmuneToEffect(e))
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExists(true,s.xyzfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local g=Duel.Select(HINTMSG_TARGET,true,tp,s.xyzfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATTACH,nil,1,PLAYER_ALL,LOCATION_MZONE,g:GetFirst())
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local ac=tc:GlitchyGetColumnGroup(1,1):FilterSelect(tp,s.atcfilter,1,1,tc,e):GetFirst()
		while ac do
			local check=ac:GlitchyGetColumnGroup(1,1):Filter(s.atcfilter,Group.FromCards(tc,ac),e)
			if Duel.Attach(ac,tc) and #check>0 then
				ac=check:Select(tp,1,1,nil):GetFirst()
			else
				ac=nil
				break
			end
		end
		if tc and tc:IsRelateToEffect(e) and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1 then
			local g=Duel.Group(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,tc)
			if #g>0 then
				Duel.BreakEffect()
				Duel.Destroy(g,REASON_EFFECT)
			end
		end
	end
end